#!/bin/bash

# Enhanced Security Hub Excel Pipeline Deployment Script
# AWS Security Hub to Excel: Enhanced GRC Automation with AI Analysis

set -e  # Exit on any error

echo "🚀 Starting Enhanced Security Hub Excel Pipeline Deployment..."

# Configuration
BUCKET_NAME="${BUCKET_NAME:-security-hub-reports-$(date +%s)}"
FUNCTION_NAME="security-hub-excel-generator-enhanced"
REGION="${AWS_REGION:-us-east-1}"

echo "📋 Configuration:"
echo "  Bucket: $BUCKET_NAME"
echo "  Function: $FUNCTION_NAME"
echo "  Region: $REGION"

# Validate AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI v2."
    exit 1
fi

# Validate AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Run 'aws configure' first."
    exit 1
fi

# Create deployment package
echo "📦 Creating deployment package..."
rm -f lambda-enhanced.zip

# Copy enhanced Lambda function and workflow integrations
if [ ! -f "lambda_function.py" ]; then
    echo "❌ lambda_function.py not found in current directory"
    exit 1
fi

if [ ! -f "workflow_integrations.py" ]; then
    echo "❌ workflow_integrations.py not found in current directory"
    exit 1
fi

# Create zip package
echo "📥 Creating deployment package..."
python -c "
import zipfile
import os

with zipfile.ZipFile('lambda-enhanced.zip', 'w') as zipf:
    zipf.write('lambda_function.py', 'lambda_function.py')
    zipf.write('workflow_integrations.py', 'workflow_integrations.py')
print('✅ Created lambda-enhanced.zip')
"

if [ ! -f "lambda-enhanced.zip" ]; then
    echo "❌ Failed to create deployment package"
    exit 1
fi

# Install dependencies
echo "📥 Installing dependencies..."
if [ ! -d "lib" ]; then
    mkdir -p lib
    pip install -r requirements.txt -t lib/
    echo "✅ Dependencies installed in lib/"
else
    echo "ℹ️ lib directory already exists"
fi

# Create S3 bucket if it doesn't exist
echo "☁️ Ensuring S3 bucket exists..."
if ! aws s3 ls "s3://$BUCKET_NAME" &> /dev/null; then
    aws s3 mb "s3://$BUCKET_NAME" --region $REGION
    echo "✅ Created S3 bucket: $BUCKET_NAME"
else
    echo "ℹ️ S3 bucket already exists: $BUCKET_NAME"
fi

# Upload to S3
echo "☁️ Uploading to S3..."
aws s3 cp lambda-enhanced.zip "s3://$BUCKET_NAME/source/lambda-enhanced.zip"

if [ $? -eq 0 ]; then
    echo "✅ Uploaded to S3: s3://$BUCKET_NAME/source/lambda-enhanced.zip"
else
    echo "❌ Failed to upload to S3"
    exit 1
fi

# Deploy CloudFormation stack
echo "🏗️ Deploying CloudFormation stack..."

# Check if stack already exists
STACK_NAME="security-hub-excel-enhanced"

if aws cloudformation describe-stacks --stack-name $STACK_NAME &> /dev/null; then
    echo "📝️ Updating existing stack..."
    aws cloudformation update-stack \
      --stack-name $STACK_NAME \
      --template-body file://cloudformation-template.yaml \
      --parameters \
        ParameterKey=S3BucketName,ParameterValue=$BUCKET_NAME \
        ParameterKey=SourceS3Key,ParameterValue=source/lambda-enhanced.zip \
        ParameterKey=FunctionName,ParameterValue=$FUNCTION_NAME \
        ParameterKey=EnableAIAnalysis,ParameterValue=true \
        ParameterKey=EnableSlack,ParameterValue=false \
        ParameterKey=EnableServiceNow,ParameterValue=false \
        ParameterKey=EnableJira,ParameterValue=false \
      --capabilities CAPABILITY_NAMED_IAM \
      --region $REGION
else
    echo "🏗️ Creating new stack..."
    aws cloudformation create-stack \
      --stack-name $STACK_NAME \
      --template-body file://cloudformation-template.yaml \
      --parameters \
        ParameterKey=S3BucketName,ParameterValue=$BUCKET_NAME \
        ParameterKey=SourceS3Key,ParameterValue=source/lambda-enhanced.zip \
        ParameterKey=FunctionName,ParameterValue=$FUNCTION_NAME \
        ParameterKey=EnableAIAnalysis,ParameterValue=true \
        ParameterKey=EnableSlack,ParameterValue=false \
        ParameterKey=EnableServiceNow,ParameterValue=false \
        ParameterKey=EnableJira,ParameterValue=false \
      --capabilities CAPABILITY_NAMED_IAM \
      --region $REGION
fi

if [ $? -eq 0 ]; then
    echo "✅ CloudFormation stack deployment initiated"
    echo "⏳ Waiting for stack creation to complete..."
    
    # Wait for stack completion
    aws cloudformation wait stack-create-complete \
      --stack-name $STACK_NAME \
      --region $REGION
    
    if [ $? -eq 0 ]; then
        echo "✅ Stack created successfully"
    else
        echo "❌ Stack creation failed"
        echo "🔍 Checking stack events..."
        aws cloudformation describe-stack-events \
          --stack-name $STACK_NAME \
          --region $REGION \
          --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].[LogicalResourceId,ResourceStatusReason]' \
          --output table
        exit 1
    fi
else
    echo "❌ CloudFormation deployment failed"
    exit 1
fi

# Get stack outputs
echo "📋 Retrieving stack outputs..."
FUNCTION_ARN=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`FunctionArn`].OutputValue' \
  --output text)

if [ -z "$FUNCTION_ARN" ]; then
    echo "❌ Failed to get function ARN from stack outputs"
    exit 1
fi

echo "✅ Function ARN: $FUNCTION_ARN"

# Test the deployment
echo "🧪 Testing deployment..."

# Wait a moment for Lambda to be ready
echo "⏳ Waiting for Lambda function to be ready..."
sleep 10

# Test the Lambda function
echo "🧪 Testing Lambda function..."
TEST_RESPONSE=$(aws lambda invoke \
  --function-name $FUNCTION_NAME \
  --region $REGION \
  --log-type Tail \
  --payload '{"test": true}' \
  response.json 2>&1)

if [ $? -eq 0 ]; then
    echo "✅ Lambda function test successful"
    echo "📊 Test response:"
    echo "$TEST_RESPONSE" | head -20
else
    echo "❌ Lambda function test failed"
    echo "🔍 Checking CloudWatch logs..."
    aws logs tail \
      --log-group-name /aws/lambda/$FUNCTION_NAME \
      --region $REGION \
      --since 1h \
      --follow &
    LOG_PID=$!
    sleep 10
    kill $LOG_PID 2>/dev/null
    exit 1
fi

# Cleanup
echo "🧹 Cleaning up temporary files..."
rm -f lambda-enhanced.zip response.json

if [ -d "lib" ]; then
    rm -rf lib
    echo "✅ Cleaned up lib directory"
fi

echo ""
echo "🎉 Enhanced Security Hub Excel Pipeline deployment completed!"
echo ""
echo "🎯 Next Steps:"
echo "1. Test with real data:"
echo "   aws lambda invoke --function-name $FUNCTION_NAME --region $REGION --output json response.json"
echo ""
echo "2. Check your S3 bucket for reports:"
echo "   aws s3 ls s3://$BUCKET_NAME/reports/"
echo ""
echo "3. Download and review enhanced Excel report:"
echo "   aws s3 cp s3://$BUCKET_NAME/reports/security_hub_report_YYYYMMDD_HHMMSS.xlsx ./enhanced-report.xlsx"
echo ""
echo "4. Configure optional integrations:"
echo "   - Enable Slack: Set ENABLE_SLACK=true and provide SLACK_WEBHOOK_URL"
echo "   - Enable ServiceNow: Set ENABLE_SERVICENOW=true and create secret with credentials"
echo "   - Enable Jira: Set ENABLE_JIRA=true and create secret with credentials"
echo "   - Enable AI Analysis: Set ENABLE_AI_ANALYSIS=true (default) and ensure Bedrock access"
echo ""
echo "📊 Enhanced Features:"
echo "  ✅ AI-powered analysis with AWS Bedrock"
echo "  ✅ Multi-framework compliance mapping (SOC 2, ISO 27001, PCI DSS, NIST)"
echo "  ✅ Interactive Excel dashboard with charts"
echo "  ✅ Pivot analysis and summary sheets"
echo "  ✅ Workflow integrations (Slack, ServiceNow, Jira)"
echo ""
echo "📚 Repository Structure:"
echo "  📄 README.md - Comprehensive documentation"
echo "  🏗️ cloudformation-template.yaml - Infrastructure as Code"
echo "  🐍 lambda_function.py - Enhanced automation logic"
echo "  🔗 workflow_integrations.py - External system integrations"
echo "  📋 requirements.txt - Python dependencies"
echo "  🚀 deploy.sh - Automated deployment script"
echo "  🚫 .gitignore - Security and exclusions"
echo ""
echo "🔒 Security Features:"
echo "  ✅ No credentials in code"
echo "  ✅ Secrets Manager integration"
echo "  ✅ IAM least privilege access"
echo "  ✅ Encrypted S3 storage"
echo "  ✅ CloudTrail audit logging"
echo ""
echo "🌟 Ready for production use!"
