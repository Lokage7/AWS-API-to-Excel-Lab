import json
import boto3
import requests
import os
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
secrets_manager = boto3.client('secretsmanager')

# Environment variables for integrations
ENABLE_SLACK = os.environ.get('ENABLE_SLACK', 'false').lower() == 'true'
ENABLE_SERVICENOW = os.environ.get('ENABLE_SERVICENOW', 'false').lower() == 'true'
ENABLE_JIRA = os.environ.get('ENABLE_JIRA', 'false').lower() == 'true'

SLACK_WEBHOOK_URL = os.environ.get('SLACK_WEBHOOK_URL')
SERVICENOW_SECRET_NAME = os.environ.get('SERVICENOW_SECRET_NAME')
JIRA_SECRET_NAME = os.environ.get('JIRA_SECRET_NAME')

def get_secret(secret_name):
    """Retrieve secret from AWS Secrets Manager"""
    try:
        response = secrets_manager.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except Exception as e:
        logger.error(f"Error retrieving secret {secret_name}: {str(e)}")
        return None

def send_slack_notification(findings, ai_analysis, report_filename):
    """Send notification to Slack with key insights"""
    if not ENABLE_SLACK or not SLACK_WEBHOOK_URL:
        logger.info("Slack integration disabled or webhook URL not configured")
        return False
    
    try:
        # Count findings by severity
        critical_count = len([f for f in findings if f.get('Severity', {}).get('Label') == 'CRITICAL'])
        high_count = len([f for f in findings if f.get('Severity', {}).get('Label') == 'HIGH'])
        
        # Create Slack message
        message = {
            "text": "🚨 Security Hub Report Generated",
            "attachments": [
                {
                    "color": "danger" if critical_count > 0 else "warning" if high_count > 0 else "good",
                    "fields": [
                        {
                            "title": "📊 Report Summary",
                            "value": f"• Total Findings: {len(findings)}\n• Critical: {critical_count}\n• High: {high_count}\n• Risk Score: {ai_analysis.get('risk_score', 'Unknown')}",
                            "short": True
                        },
                        {
                            "title": "🤖 AI Analysis",
                            "value": ai_analysis.get('summary', 'Analysis unavailable'),
                            "short": False
                        },
                        {
                            "title": "📋 Top Recommendations",
                            "value": "\n".join([f"• {rec}" for rec in ai_analysis.get('recommendations', [])[:3]]),
                            "short": False
                        },
                        {
                            "title": "📁 Report File",
                            "value": f"`{report_filename}`",
                            "short": True
                        }
                    ],
                    "footer": "AWS Security Hub Automation",
                    "ts": int(datetime.now().timestamp())
                }
            ]
        }
        
        # Send to Slack
        response = requests.post(SLACK_WEBHOOK_URL, json=message)
        response.raise_for_status()
        
        logger.info("Slack notification sent successfully")
        return True
        
    except Exception as e:
        logger.error(f"Error sending Slack notification: {str(e)}")
        return False

def create_servicenow_tickets(findings):
    """Create ServiceNow tickets for critical and high findings"""
    if not ENABLE_SERVICENOW or not SERVICENOW_SECRET_NAME:
        logger.info("ServiceNow integration disabled")
        return []
    
    try:
        # Get ServiceNow credentials
        servicenow_creds = get_secret(SERVICENOW_SECRET_NAME)
        if not servicenow_creds:
            return []
        
        instance_url = servicenow_creds.get('instance_url')
        username = servicenow_creds.get('username')
        password = servicenow_creds.get('password')
        
        if not all([instance_url, username, password]):
            logger.error("ServiceNow credentials incomplete")
            return []
        
        # Filter for critical and high findings
        critical_findings = [f for f in findings if f.get('Severity', {}).get('Label') in ['CRITICAL', 'HIGH']]
        tickets_created = []
        
        for finding in critical_findings:
            try:
                # Create ServiceNow incident
                incident_data = {
                    "short_description": f"Security Finding: {finding.get('Title', 'Unknown')}",
                    "description": f"""
Security Hub Finding Details:

Title: {finding.get('Title', 'N/A')}
Severity: {finding.get('Severity', {}).get('Label', 'N/A')}
Description: {finding.get('Description', 'N/A')}
Resource Type: {finding.get('Resources', [{}])[0].get('Type', 'N/A')}
Region: {finding.get('Resources', [{}])[0].get('Region', 'N/A')}
First Seen: {finding.get('FirstObservedAt', 'N/A')}
Generator ID: {finding.get('GeneratorId', 'N/A')}

Remediation:
{finding.get('Remediation', {}).get('Recommendation', {}).get('Text', 'N/A')}

Finding ID: {finding.get('Id', 'N/A')}
                    """.strip(),
                    "urgency": "1" if finding.get('Severity', {}).get('Label') == 'CRITICAL' else "2",
                    "impact": "2",
                    "category": "Security",
                    "subcategory": "Vulnerability",
                    "assignment_group": "Security Team"
                }
                
                # Make API call to ServiceNow
                headers = {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }
                
                auth = (username, password)
                url = f"{instance_url}/api/now/table/incident"
                
                response = requests.post(url, headers=headers, auth=auth, json=incident_data)
                response.raise_for_status()
                
                incident = response.json()
                ticket_number = incident.get('result', {}).get('number')
                
                if ticket_number:
                    tickets_created.append({
                        'finding_id': finding.get('Id'),
                        'ticket_number': ticket_number,
                        'severity': finding.get('Severity', {}).get('Label')
                    })
                    logger.info(f"Created ServiceNow ticket {ticket_number} for finding {finding.get('Id')}")
                
            except Exception as e:
                logger.error(f"Error creating ServiceNow ticket for finding {finding.get('Id')}: {str(e)}")
                continue
        
        return tickets_created
        
    except Exception as e:
        logger.error(f"Error in ServiceNow integration: {str(e)}")
        return []

def create_jira_tickets(findings):
    """Create Jira tickets for critical and high findings"""
    if not ENABLE_JIRA or not JIRA_SECRET_NAME:
        logger.info("Jira integration disabled")
        return []
    
    try:
        # Get Jira credentials
        jira_creds = get_secret(JIRA_SECRET_NAME)
        if not jira_creds:
            return []
        
        jira_url = jira_creds.get('jira_url')
        username = jira_creds.get('username')
        api_token = jira_creds.get('api_token')
        project_key = jira_creds.get('project_key', 'SEC')
        
        if not all([jira_url, username, api_token]):
            logger.error("Jira credentials incomplete")
            return []
        
        # Filter for critical and high findings
        critical_findings = [f for f in findings if f.get('Severity', {}).get('Label') in ['CRITICAL', 'HIGH']]
        tickets_created = []
        
        for finding in critical_findings:
            try:
                # Create Jira issue
                issue_data = {
                    "fields": {
                        "project": {"key": project_key},
                        "summary": f"Security Finding: {finding.get('Title', 'Unknown')}",
                        "description": f"""
h2. Security Hub Finding Details

*Title:* {finding.get('Title', 'N/A')}
*Severity:* {finding.get('Severity', {}).get('Label', 'N/A')}
*Resource Type:* {finding.get('Resources', [{}])[0].get('Type', 'N/A')}
*Region:* {finding.get('Resources', [{}])[0].get('Region', 'N/A')}
*First Seen:* {finding.get('FirstObservedAt', 'N/A')}
*Generator ID:* {finding.get('GeneratorId', 'N/A')}

h2. Description
{finding.get('Description', 'N/A')}

h2. Remediation
{finding.get('Remediation', {}).get('Recommendation', {}).get('Text', 'N/A')}

h2. Finding ID
{finding.get('Id', 'N/A')}
                        """.strip(),
                        "issuetype": {"name": "Task"},
                        "priority": {"name": "Highest" if finding.get('Severity', {}).get('Label') == 'CRITICAL' else "High"},
                        "labels": ["security-hub", "automated", finding.get('Severity', {}).get('Label', '').lower()]
                    }
                }
                
                # Make API call to Jira
                headers = {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }
                
                auth = (username, api_token)
                url = f"{jira_url}/rest/api/2/issue"
                
                response = requests.post(url, headers=headers, auth=auth, json=issue_data)
                response.raise_for_status()
                
                issue = response.json()
                ticket_key = issue.get('key')
                
                if ticket_key:
                    tickets_created.append({
                        'finding_id': finding.get('Id'),
                        'ticket_key': ticket_key,
                        'severity': finding.get('Severity', {}).get('Label')
                    })
                    logger.info(f"Created Jira ticket {ticket_key} for finding {finding.get('Id')}")
                
            except Exception as e:
                logger.error(f"Error creating Jira ticket for finding {finding.get('Id')}: {str(e)}")
                continue
        
        return tickets_created
        
    except Exception as e:
        logger.error(f"Error in Jira integration: {str(e)}")
        return []

def execute_workflow_integrations(findings, ai_analysis, report_filename):
    """Execute all enabled workflow integrations"""
    integration_results = {
        'slack_sent': False,
        'servicenow_tickets': [],
        'jira_tickets': []
    }
    
    # Send Slack notification
    if ENABLE_SLACK:
        integration_results['slack_sent'] = send_slack_notification(findings, ai_analysis, report_filename)
    
    # Create ServiceNow tickets
    if ENABLE_SERVICENOW:
        integration_results['servicenow_tickets'] = create_servicenow_tickets(findings)
    
    # Create Jira tickets
    if ENABLE_JIRA:
        integration_results['jira_tickets'] = create_jira_tickets(findings)
    
    return integration_results
