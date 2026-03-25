# Architecture Diagram Documentation

## System Overview

The Enhanced Security Hub Excel Pipeline demonstrates a modern, serverless GRC automation architecture that bridges the gap between technical security data and business compliance requirements.

## Component Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        AWS Cloud Environment                           │
│                                                                 │
│  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────────┐    ┌──────────────┐    │
│  │   AWS       │    │   AWS        │    │   AWS       │    │   External     │    │   Audit      │    │
│  │ Security    │───▶│   Lambda     │───▶│   Bedrock   │───▶│   Systems      │───▶│   Teams      │    │
│  │   Hub       │    │  (Enhanced)  │    │  (AI       │    │  (ServiceNow, │    │  (Excel     │    │
│  │ (100+ Tools)│    │              │    │  Analysis)  │    │   Jira, Slack)│    │  Users)      │    │
│  └─────────────┘    └──────────────┘    └─────────────┘    └─────────────────┘    └──────────────┘    │
│         │                       │                       │                       │                       │
│         ▼                       ▼                       ▼                       ▼
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                    AWS S3 (Reports)                │    │
│  │  • Executive Summary  • Detailed Findings           │    │
│  │  • Compliance Mapping • Dashboard & Charts            │    │
│  │  • Pivot Analysis    • Workflow Integrations         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                              │                                          │
│                              ▼                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                 End Users & Stakeholders                │    │
│  │  • GRC Engineers  • Audit Teams                 │    │
│  │  • Executives     • Compliance Officers           │    │
│  │  • Security Teams  • External Auditors             │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow

1. **Data Collection**: AWS Security Hub aggregates findings from 100+ security services
2. **AI Processing**: AWS Bedrock analyzes findings patterns and generates insights
3. **Excel Generation**: Lambda creates multi-sheet Excel reports with visualizations
4. **Storage**: Reports stored in S3 with encryption and lifecycle policies
5. **Distribution**: Downloaded by audit teams or integrated via external systems
6. **Workflow Automation**: Critical findings trigger ticket creation and notifications

## Security Architecture

### IAM Role Security
- **Least Privilege**: Role-based access with minimal required permissions
- **Service-Based Trust**: Lambda service trust relationship
- **Resource Isolation**: Separate roles for different environments
- **Audit Logging**: CloudTrail integration for all API calls

### Data Protection
- **Encryption in Transit**: HTTPS/TLS for all external communications
- **Encryption at Rest**: S3 server-side encryption (AES-256)
- **Secrets Management**: AWS Secrets Manager for external credentials
- **Access Controls**: VPC endpoints and security group restrictions

### Compliance Controls
- **Change Management**: CloudFormation with version control
- **Audit Trail**: Complete logging of all system activities
- **Data Retention**: Configurable S3 lifecycle policies
- **Access Monitoring**: CloudWatch logs and metrics

## Technology Stack

| Layer | Technology | Purpose | Configuration |
|--------|-----------|---------|-------------|
| **Compute** | AWS Lambda | Python 3.9, 512MB RAM, 300s timeout |
| **AI/ML** | AWS Bedrock | Claude 3 Haiku model for analysis |
| **Storage** | AWS S3 | Standard class, lifecycle policies, encryption |
| **Infrastructure** | AWS CloudFormation | Infrastructure as Code, version control |
| **Monitoring** | AWS CloudWatch | Log aggregation, metrics, alarms |
| **Integration** | REST APIs | ServiceNow, Jira, Slack webhooks |
| **Security** | AWS IAM | Role-based access, secrets management |

## Scaling Characteristics

### Horizontal Scaling
- **Multiple Regions**: Deployable across AWS regions
- **Multi-Account**: Support for AWS Organizations
- **Concurrent Executions**: Up to 1000 parallel Lambda functions
- **Load Balancing**: S3 distribution and CloudFront options

### Vertical Scaling
- **Memory Configuration**: 128MB to 3GB Lambda memory
- **Processing Power**: Adjust timeout based on findings volume
- **Batch Processing**: Configurable batch sizes for large datasets
- **Performance Optimization**: Cold start mitigation and provisioned concurrency

## Cost Architecture

### Pay-Per-Use Model
- **Lambda**: $0.0000002 per request + compute time
- **Bedrock**: $0.00025 per 1K tokens
- **S3**: $0.023 per GB-month + data transfer
- **Data Transfer**: $0.09 per GB (first 10GB free)
- **Integration**: No additional costs for API calls

### Cost Optimization
- **Serverless**: No infrastructure costs when not running
- **Efficient Processing**: Optimized Python code and libraries
- **Smart Caching**: Reuse of common data patterns
- **Lifecycle Management**: Automatic cleanup of old reports

## Deployment Architecture

### Environment Strategy
- **Development**: Local testing with SAM CLI or direct deployment
- **Staging**: Separate AWS account for integration testing
- **Production**: CloudFormation stack with automated deployment
- **Disaster Recovery**: Cross-region replication and backup procedures

### CI/CD Pipeline
```
Git Repository → Code Build → Test Suite → Security Scan → Deploy to Staging → Manual Approval → Production Deployment
```

### Monitoring & Observability
- **Application Metrics**: Lambda function performance and error rates
- **Business Metrics**: Report generation frequency and user adoption
- **Security Monitoring**: IAM access patterns and API call analysis
- **Cost Monitoring**: Monthly spend tracking and optimization recommendations

## Integration Points

### Ingestion APIs
- **AWS Security Hub**: Real-time findings stream
- **AWS Config**: Configuration change notifications
- **AWS CloudTrail**: Audit log integration
- **Custom Sources**: Extensible framework for additional security tools

### Output Formats
- **Excel Workbook**: Multi-sheet, formatted reports
- **JSON API**: RESTful interface for integrations
- **PDF Reports**: Printable audit documentation
- **CSV Export**: Data portability and analysis

This architecture demonstrates how modern GRC automation can leverage cloud-native services to create scalable, secure, and cost-effective solutions that meet both technical and business requirements.
