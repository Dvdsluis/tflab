#!/bin/bash
# Web Server User Data Script
# This script sets up a simple nginx web server with a basic HTML page

# Update the system
yum update -y

# Install nginx
amazon-linux-extras install nginx1 -y

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

# Create a simple index page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Terraform Lab - Web Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .info-box {
            background-color: #ecf0f1;
            padding: 15px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .status {
            color: #27ae60;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Terraform Lab - Web Server</h1>
            <p>Welcome to your Terraform Infrastructure Lab!</p>
        </div>
        
        <div class="info-box">
            <h3>Server Information</h3>
            <p><strong>Instance ID:</strong> <span id="instanceId">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
            <p><strong>Status:</strong> <span class="status">✅ Web Server Running</span></p>
        </div>
        
        <div class="info-box">
            <h3>Architecture Overview</h3>
            <p>This web server is part of a multi-tier architecture:</p>
            <ul>
                <li><strong>Web Tier:</strong> You are here! (Public subnet)</li>
                <li><strong>App Tier:</strong> Application servers (Private subnet)</li>
                <li><strong>Database Tier:</strong> RDS Database (Database subnet)</li>
            </ul>
        </div>
        
        <div class="info-box">
            <h3>App Server Connection</h3>
            <p><strong>App Load Balancer:</strong> ${app_lb_dns}</p>
            <p id="appStatus">Checking app server connection...</p>
        </div>
        
        <div class="info-box">
            <h3>Learning Objectives</h3>
            <ul>
                <li>Root and child module composition</li>
                <li>Variable inheritance patterns</li>
                <li>Infrastructure testing with Terratest</li>
                <li>Documentation generation</li>
                <li>Multi-environment deployments</li>
            </ul>
        </div>
    </div>
    
    <script>
        // Fetch instance metadata
        fetch('/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instanceId').textContent = data)
            .catch(error => document.getElementById('instanceId').textContent = 'Unable to fetch');
            
        fetch('/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('az').textContent = data)
            .catch(error => document.getElementById('az').textContent = 'Unable to fetch');
            
        // Test app server connection
        fetch('http://${app_lb_dns}:8080/health')
            .then(response => response.text())
            .then(data => {
                document.getElementById('appStatus').innerHTML = 
                    '<span class="status">✅ App servers are healthy</span>';
            })
            .catch(error => {
                document.getElementById('appStatus').innerHTML = 
                    '<span style="color: #e74c3c;">❌ App servers not reachable</span>';
            });
    </script>
</body>
</html>
EOF

# Configure nginx to proxy requests to app servers
cat > /etc/nginx/conf.d/app.conf << 'EOF'
upstream app_servers {
    server ${app_lb_dns}:8080;
}

server {
    listen 80;
    server_name _;
    
    location /api/ {
        proxy_pass http://app_servers/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Restart nginx to apply configuration
systemctl restart nginx

# Install CloudWatch agent for monitoring
yum install -y amazon-cloudwatch-agent

# Create CloudWatch config
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "metrics": {
        "namespace": "TerraformLab/WebServer",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/terraform-lab/web/nginx/access",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/terraform-lab/web/nginx/error",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

echo "Web server setup completed successfully!"