# AWS Security Hub to Excel Pipeline: Enhanced GRC Automation

**GRC Engineering Club — Bridging Technical Security Data and Business Compliance**

This project transforms AWS Security Hub findings into comprehensive, audit-ready Excel reports with AI-powered insights, multi-framework compliance mapping, and workflow automation. It demonstrates how GRC engineers can bridge the gap between technical security data and business compliance requirements.

---

## 🎯 Project Overview

### The Problem
There's a fundamental disconnect in most organizations between how GRC engineers work and how audit teams consume information. GRC teams embrace APIs, dashboards, and automated workflows with enthusiasm. Audit teams, however, live and breathe Excel.

### The Solution
Rather than trying to convince audit teams to adopt new tools, this approach automates the creation of audit-ready Excel reports directly from AWS Security Hub. GRC teams get their beloved automation while audit teams receive their preferred Excel deliverables.

### What You'll Learn & Build

| GRC Skill | Technical Implementation | Business Value |
|-------------|----------------------|------------------|
| **API Integration** | AWS Security Hub, Bedrock, S3, Lambda | Automated data extraction from 100+ security tools |
| **Compliance Mapping** | Multi-framework mapping (SOC 2, ISO 27001, PCI DSS, NIST) | Audit-ready documentation with control alignment |
| **AI-Powered Analysis** | AWS Bedrock integration with Claude 3 | Executive summaries and risk scoring |
| **Excel Automation** | Advanced Excel generation with charts, pivots, formatting | Professional audit deliverables |
| **Workflow Integration** | ServiceNow, Jira, Slack APIs | Automated ticketing and notifications |
| **Serverless Architecture** | Lambda functions, CloudFormation, IAM | Scalable, pay-per-use infrastructure |

---

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│  AWS Security   │    │   AWS Lambda  │    │   AWS Bedrock   │
│     Hub         │───▶│  (Enhanced)   │───▶│   (AI Analysis)  │
│  (100+ Tools)   │    │              │    │                 │
└─────────────────┘    └──────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   AWS S3 (Reports)                        │
│  • Executive Summary  • Detailed Findings                │
│  • Compliance Mapping • Dashboard & Charts                 │
│  • Pivot Analysis    • Workflow Integrations             │
└─────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                 External Systems                              │
│  • Slack Notifications  • ServiceNow Tickets               │
│  • Jira Issues        • Audit Teams                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

### AWS Account Setup
- **AWS Account**: Free tier account with billing alerts enabled
- **IAM Permissions**: SecurityHub, Lambda, S3, CloudFormation, Bedrock, SecretsManager
- **Security Hub**: Enabled with active findings
- **MFA Required**: Immediately enable on root account (IA-2 control)

### Development Environment
| Platform | Recommended Tool | Setup Command |
|-----------|------------------|----------------|
| Windows | PowerShell (built-in) | `ssh -V` to verify OpenSSH |
| macOS | Built-in Terminal | `brew install awscli terraform` |
| Linux | Built-in Terminal | `sudo apt install awscli terraform` |

### AWS CLI Configuration
```bash
aws configure
# Prompts: Access Key ID, Secret Access Key, Region, Output format
```

---

## 🚀 Quick Start

### Option 1: Automated Deployment (Recommended)
```bash
# Clone and deploy
git clone <your-repo>
cd aws-security-hub-excel-pipeline
chmod +x deploy.sh
./deploy.sh
```

### Option 2: Step-by-Step Manual Deployment
1. **Infrastructure Setup**
   ```bash
   aws cloudformation create-stack \
     --stack-name security-hub-excel \
     --template-body file://cloudformation-template.yaml \
     --capabilities CAPABILITY_NAMED_IAM
   ```

2. **Lambda Function Deployment**
   ```bash
   zip -r enhanced-lambda.zip lambda_function.py workflow_integrations.py
   aws lambda update-function-code \
     --function-name security-hub-excel-generator \
     --zip-file fileb://enhanced-lambda.zip
   ```

3. **Configuration**
   ```bash
   aws lambda update-function-configuration \
     --function-name security-hub-excel-generator \
     --environment Variables='{
         ENABLE_AI_ANALYSIS="true",
         ENABLE_SLACK="false",
         ENABLE_SERVICENOW="false",
         ENABLE_JIRA="false"
       }'
   ```

---

## 📊 Enhanced Features

### 🤖 AI-Powered Analysis (AWS Bedrock)
- **Executive Summaries**: C-suite ready insights in natural language
- **Risk Scoring**: AI-powered assessment based on findings patterns
- **Smart Recommendations**: Prioritized remediation suggestions
- **Natural Language Processing**: Human-readable insights from technical data

### 📋 Advanced Compliance Mapping
- **Multi-Standard Support**: SOC 2, ISO 27001, PCI DSS, NIST frameworks
- **Automatic Mapping**: Keyword-based intelligent framework alignment
- **Control Tracking**: Direct mapping to specific compliance controls
- **Audit Documentation**: Complete compliance evidence package

### 📈 Excel Optimization & Visualization
- **5 Professional Sheets**:
  - **Executive Summary**: AI insights + key metrics dashboard
  - **Detailed Findings**: Comprehensive data export with all metadata
  - **Compliance Mapping**: Framework alignment and control relationships
  - **Dashboard**: Interactive charts and visualizations
  - **Pivot Analysis**: Aggregated data views and trends
- **Interactive Charts**: Severity distribution, trend analysis, heat maps
- **Professional Formatting**: Corporate-ready styling and auto-sizing

### 🔗 Workflow Integrations
- **Slack Notifications**: Real-time alerts with key insights and metrics
- **ServiceNow Integration**: Automatic ticket creation for critical findings
- **Jira Integration**: Issue tracking and assignment for remediation
- **Configurable Triggers**: Enable/disable integrations per environment

---

## 🧪 Repository Structure

```
aws-security-hub-excel-pipeline/
├── README.md                    # This comprehensive overview
├── cloudformation-template.yaml  # Infrastructure as Code
├── lambda_function.py           # Enhanced main Lambda function
├── workflow_integrations.py    # External system integrations
├── requirements.txt             # Python dependencies
├── deploy.sh                  # Automated deployment script
├── .gitignore                 # Excludes credentials and temp files
└── docs/                      # Additional documentation
    ├── architecture-diagram.md
    ├── api-reference.md
    └── troubleshooting.md
```

### File Descriptions

| File | Purpose | Key Features |
|-------|---------|--------------|
| `lambda_function.py` | Core automation logic | AI analysis, Excel generation, compliance mapping |
| `workflow_integrations.py` | External integrations | Slack, ServiceNow, Jira APIs |
| `cloudformation-template.yaml` | Infrastructure as Code | IAM roles, Lambda function, S3 permissions |
| `deploy.sh` | One-command deployment | Error handling, validation, cleanup |
| `requirements.txt` | Dependencies | OpenPyXL, Boto3, Requests |

---

## 🎯 GRC Control Mappings

Each component maps to specific NIST 800-53 controls:

| Lab Component | NIST Control | Control Name | Implementation |
|---------------|---------------|--------------|-----------------|
| **AWS Security Hub** | CM-8 | System Component Inventory | Automated finding collection from 100+ tools |
| **Lambda Functions** | CM-2 | Baseline Configuration | Infrastructure as Code with version control |
| **IAM Roles** | AC-2, IA-5 | Access Control | Least privilege, automated credential management |
| **Bedrock Integration** | AU-6 | Audit Review | AI-powered analysis and documentation |
| **Excel Reports** | SI-4 | Information System Monitoring | Automated compliance reporting |
| **S3 Storage** | SC-28 | Protection at Rest | Encrypted storage with lifecycle policies |
| **ServiceNow/Jira** | SI-2 | Flaw Remediation | Automatic ticket creation and tracking |
| **Slack Notifications** | IR-4 | Incident Handling | Real-time security alerts |
| **CloudFormation** | CM-3 | Configuration Change Control | Version-controlled infrastructure changes |

---

## 🧪 Testing & Validation

### Unit Testing
```bash
# Test Lambda function locally
python -m pytest tests/

# Validate CloudFormation template
aws cloudformation validate-template --template-body file://cloudformation-template.yaml
```

### Integration Testing
```bash
# Test Security Hub access
aws securityhub get-findings --max-results 1

# Test Bedrock access
aws bedrock list-foundation-models

# Test S3 upload
aws s3 cp test.txt s3://$BUCKET_NAME/test
```

### End-to-End Testing
```bash
# Generate test report
aws lambda invoke \
  --function-name security-hub-excel-generator \
  --payload '{"test": true}' \
  response.json

# Verify Excel file generation
aws s3 ls s3://$BUCKET_NAME/reports/
```

---

## 🔧 Configuration Options

### Environment Variables

| Variable | Default | Description |
|-----------|---------|-------------|
| `ENABLE_AI_ANALYSIS` | `true` | Enable/disable AWS Bedrock AI analysis |
| `BEDROCK_MODEL_ID` | `anthropic.claude-3-haiku-20240307-v1:0` | Bedrock model for AI analysis |
| `ENABLE_SLACK` | `false` | Enable Slack notifications |
| `ENABLE_SERVICENOW` | `false` | Enable ServiceNow ticket creation |
| `ENABLE_JIRA` | `false` | Enable Jira issue creation |

### Advanced Configuration

#### Slack Integration
```bash
# Set webhook URL
aws lambda update-function-configuration \
  --function-name security-hub-excel-generator \
  --environment Variables='{
      ENABLE_SLACK="true",
      SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    }'
```

#### ServiceNow Integration
```bash
# Store credentials in Secrets Manager
aws secretsmanager create-secret \
  --name security-hub-servicenow-creds \
  --secret-string '{
      "instance_url": "https://your-instance.service-now.com",
      "username": "your-username",
      "password": "your-password"
    }'
```

#### Jira Integration
```bash
# Store credentials in Secrets Manager
aws secretsmanager create-secret \
  --name security-hub-jira-creds \
  --secret-string '{
      "jira_url": "https://your-domain.atlassian.net",
      "username": "your-email@company.com",
      "api_token": "your-api-token",
      "project_key": "SEC"
    }'
```

---

## 📈 Performance & Cost Analysis

### Lambda Configuration
- **Memory**: 512MB (adjustable based on findings volume)
- **Timeout**: 300 seconds (5 minutes)
- **Runtime**: Python 3.9
- **Concurrent Executions**: Up to 1000

### Cost Optimization
| Component | Cost Model | Monthly Estimate (1000 findings) |
|-----------|------------|------------------------------|
| **Lambda** | $0.0000002 per request + compute time | ~$2-5 |
| **Bedrock** | $0.00025 per 1K tokens | ~$1-3 |
| **S3 Storage** | $0.023 per GB | ~$0.50 |
| **Data Transfer** | $0.09 per GB | ~$0.10 |
| **Total** | | **~$4-9 per month** |

### Scaling Considerations
- **Findings Volume**: Supports up to 1000 findings per execution
- **Batch Processing**: Configurable batch sizes for large datasets
- **Parallel Processing**: Multiple concurrent executions possible
- **Regional Deployment**: Multi-region support for global compliance

---

## 🔒 Security Considerations

### IAM Security
- **Least Privilege**: Role-based access with minimal permissions
- **Secrets Management**: External credentials stored in AWS Secrets Manager
- **Resource Policies**: S3 bucket policies with encryption requirements
- **Network Security**: VPC-compatible deployment options

### Data Privacy
- **No Logging**: Sensitive finding data not logged or transmitted
- **Encrypted Storage**: S3 server-side encryption enabled
- **Secure Transmission**: HTTPS for all external API calls
- **Audit Trail**: CloudTrail integration for compliance

### Compliance Alignment
- **SOC 2**: Access control, monitoring, and change management
- **ISO 27001**: Information security management system
- **PCI DSS**: Payment card industry data protection
- **NIST 800-53**: Federal information system controls

---

## 🛠️ Troubleshooting Guide

### Common Issues & Solutions

| Issue | Symptoms | Solution |
|--------|------------|----------|
| **Bedrock Access Denied** | `AccessDeniedException` | Enable Bedrock model access in AWS console |
| **Lambda Timeouts** | `Task timed out` | Increase timeout or memory size |
| **S3 Permission Errors** | `AccessDenied` | Verify IAM role S3 permissions |
| **Slack Webhook Failures** | No notifications | Test webhook URL and network connectivity |
| **ServiceNow API Errors** | `401 Unauthorized` | Verify credentials and instance URL |
| **Empty Excel Reports** | 0KB file size | Check Security Hub for active findings |

### Debug Commands

```bash
# Check Lambda logs
aws logs tail /aws/lambda/security-hub-excel-generator --follow

# Test individual components
aws securityhub get-findings --max-results 1
aws bedrock invoke-model --model-id anthropic.claude-3-haiku-20240307-v1:0 --body '{"inputText": "test"}'

# Verify permissions
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::703959535548:role/security-hub-lambda-role --action-names "securityhub:GetFindings"
```

---

## 📚 Additional Resources

### Documentation
- **AWS Security Hub User Guide**: [Official Documentation](https://docs.aws.amazon.com/security-hub/)
- **AWS Bedrock Developer Guide**: [AI/ML Documentation](https://docs.aws.amazon.com/bedrock/)
- **OpenPyXL Documentation**: [Excel Manipulation](https://openpyxl.readthedocs.io/)
- **CloudFormation User Guide**: [Infrastructure as Code](https://docs.aws.amazon.com/cloudformation/)

### Compliance Frameworks
- **SOC 2**: [AICPA Service Organization Control Reports](https://www.aicpa.org/soc)
- **ISO 27001**: [Information Security Management](https://www.iso.org/isoiec-27001-information-security.html)
- **PCI DSS**: [Payment Card Industry Data Security](https://www.pcisecuritystandards.org/)
- **NIST 800-53**: [Federal Information Systems](https://csrc.nist.gov/publications/detail/sp/800-53)

### API References
- **AWS Security Hub API**: [Findings API](https://docs.aws.amazon.com/security-hub/latest/userguide/securityhub-api-reference.html)
- **AWS Lambda API**: [Function Configuration](https://docs.aws.amazon.com/lambda/latest/dg/configuration-function-common.html)
- **ServiceNow REST API**: [Table API](https://docs.servicenow.com/bundle/paris-api-now/page/rest/table-api.html)
- **Jira REST API**: [Issue API](https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issue-api/)

---

## 🤝 Contributing

### Code Standards
- **Python**: Follow PEP 8 style guidelines
- **CloudFormation**: Use YAML best practices
- **Documentation**: Update README for new features
- **Security**: Never commit credentials or sensitive data

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

---

## 🆘 Support & Community

### Getting Help
1. **Check CloudWatch Logs**: First stop for debugging issues
2. **Verify IAM Permissions**: Common root cause of failures
3. **Test Individual Components**: Isolate problematic integration
4. **Review Environment Variables**: Configuration errors are frequent

### Community
- **Issues**: Report bugs and feature requests via GitHub Issues
- **Discussions**: Share experiences and best practices
- **Contributions**: Pull requests welcome from all skill levels

---

**Built by GRC Engineering Club - Demonstrating how technical automation and business compliance can work together seamlessly.**

*This project represents more than just code—it's a bridge between two worlds that need to work together, wrapped in technology that makes everyone's job easier and more effective.*
