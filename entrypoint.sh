#!/bin/sh

echo "=== Starting Demo API with Dynatrace OneAgent ==="

# Check if Dynatrace is configured
if [ -n "$DT_API_TOKEN" ] && [ -n "$DT_TENANT" ]; then
    echo "Dynatrace configuration detected..."
    echo "Tenant: $DT_TENANT"
    
    # Download Dynatrace OneAgent
    echo "Downloading Dynatrace OneAgent..."
    DOWNLOAD_URL="https://${DT_TENANT}.live.dynatrace.com/api/v1/deployment/installer/agent/unix/paas/latest?Api-Token=${DT_API_TOKEN}&arch=x86&flavor=default"
    
    if curl -L -o /tmp/oneagent.zip "$DOWNLOAD_URL" 2>/dev/null; then
        echo "OneAgent downloaded successfully"
        
        # Verify it's a valid zip file
        if unzip -t /tmp/oneagent.zip >/dev/null 2>&1; then
            echo "Extracting OneAgent..."
            unzip -o /tmp/oneagent.zip -d / >/dev/null 2>&1
            rm /tmp/oneagent.zip
            
            # Set Dynatrace environment variables
            export DT_CONNECTION_POINT="https://${DT_TENANT}.live.dynatrace.com:443"
            
            # Check if agent library exists
            if [ -f "/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so" ]; then
                echo "✓ Dynatrace OneAgent installed successfully"
                echo "✓ Connection Point: $DT_CONNECTION_POINT"
                echo "✓ Starting Java application with Dynatrace instrumentation..."
                echo ""
                exec java -agentpath:/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so -jar /app/app.jar
            else
                echo "⚠ Agent library not found, starting without instrumentation..."
                exec java -jar /app/app.jar
            fi
        else
            echo "⚠ Downloaded file is not a valid ZIP, starting without Dynatrace..."
            rm -f /tmp/oneagent.zip
            exec java -jar /app/app.jar
        fi
    else
        echo "⚠ Failed to download OneAgent, starting without Dynatrace..."
        exec java -jar /app/app.jar
    fi
else
    echo "Dynatrace not configured, starting application normally..."
    exec java -jar /app/app.jar
fi
