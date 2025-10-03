#!/bin/bash
# App Server User Data Script
# This script sets up a simple Node.js application server

# Update the system
yum update -y

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Create package.json
cat > package.json << 'EOF'
{
  "name": "terraform-lab-app",
  "version": "1.0.0",
  "description": "Simple app server for Terraform lab",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
EOF

# Install dependencies
npm install

# Create the main application file
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const app = express();
const port = 8080;

// Middleware
app.use(cors());
app.use(express.json());

// Get instance metadata
const getInstanceMetadata = async (path) => {
  try {
    const response = await fetch(`http://169.254.169.254/latest/meta-data/${path}`);
    return await response.text();
  } catch (error) {
    return 'Unknown';
  }
};

// Routes
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/info', async (req, res) => {
  try {
    const instanceId = await getInstanceMetadata('instance-id');
    const az = await getInstanceMetadata('placement/availability-zone');
    const instanceType = await getInstanceMetadata('instance-type');
    
    res.json({
      instanceId,
      availabilityZone: az,
      instanceType,
      nodeVersion: process.version,
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({ error: 'Unable to fetch instance metadata' });
  }
});

app.get('/api/status', (req, res) => {
  res.json({
    service: 'Terraform Lab App Server',
    status: 'running',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/data', (req, res) => {
  const sampleData = {
    users: [
      { id: 1, name: 'Alice', role: 'admin' },
      { id: 2, name: 'Bob', role: 'user' },
      { id: 3, name: 'Charlie', role: 'user' }
    ],
    products: [
      { id: 1, name: 'Widget A', price: 19.99 },
      { id: 2, name: 'Widget B', price: 29.99 },
      { id: 3, name: 'Widget C', price: 39.99 }
    ],
    orders: [
      { id: 1, userId: 1, productId: 1, quantity: 2 },
      { id: 2, userId: 2, productId: 2, quantity: 1 },
      { id: 3, userId: 3, productId: 3, quantity: 3 }
    ]
  };
  
  res.json({
    data: sampleData,
    timestamp: new Date().toISOString(),
    source: 'terraform-lab-app-server'
  });
});

app.post('/api/echo', (req, res) => {
  res.json({
    message: 'Echo successful',
    receivedData: req.body,
    timestamp: new Date().toISOString()
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`Terraform Lab App Server running on port ${port}`);
  console.log(`Health check: http://localhost:${port}/health`);
  console.log(`Info endpoint: http://localhost:${port}/info`);
  console.log(`API endpoints: http://localhost:${port}/api/status`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});
EOF

# Create systemd service
cat > /etc/systemd/system/terraform-lab-app.service << 'EOF'
[Unit]
Description=Terraform Lab App Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R ec2-user:ec2-user /opt/app

# Enable and start the service
systemctl daemon-reload
systemctl enable terraform-lab-app
systemctl start terraform-lab-app

# Install CloudWatch agent for monitoring
yum install -y amazon-cloudwatch-agent

# Create CloudWatch config
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "metrics": {
        "namespace": "TerraformLab/AppServer",
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
                        "file_path": "/var/log/messages",
                        "log_group_name": "/terraform-lab/app/system",
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

echo "App server setup completed successfully!"