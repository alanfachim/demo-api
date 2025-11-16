#!/bin/sh

# Download Dynatrace OneAgent if token is provided
if [ -n "$DT_API_TOKEN" ] && [ -n "$DT_TENANT" ]; then
    echo "Downloading Dynatrace OneAgent..."
    curl -L -o /tmp/oneagent.zip "https://${DT_TENANT}.live.dynatrace.com/api/v1/deployment/installer/agent/unix/paas/latest?Api-Token=${DT_API_TOKEN}&arch=x86&flavor=default"
    unzip -o /tmp/oneagent.zip -d /
    rm /tmp/oneagent.zip
    
    # Set connection point
    export DT_CONNECTION_POINT="https://${DT_TENANT}.live.dynatrace.com:443"
    
    # Start Java with agent
    exec java -agentpath:/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so -jar /app/app.jar
else
    echo "Dynatrace not configured, starting without agent..."
    exec java -jar /app/app.jar
fi
