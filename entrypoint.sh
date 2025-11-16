#!/bin/sh

# Download Dynatrace OneAgent if token is provided
if [ -n "$DT_API_TOKEN" ] && [ -n "$DT_TENANT" ]; then
    echo "Downloading Dynatrace OneAgent..."
    HTTP_CODE=$(curl -L -w "%{http_code}" -o /tmp/oneagent.zip "https://${DT_TENANT}.live.dynatrace.com/api/v1/deployment/installer/agent/unix/paas/latest?Api-Token=${DT_API_TOKEN}&arch=x86&flavor=default")
    
    if [ "$HTTP_CODE" -eq 200 ] && [ -s /tmp/oneagent.zip ]; then
        # Check if file is actually a zip
        if unzip -t /tmp/oneagent.zip > /dev/null 2>&1; then
            echo "OneAgent downloaded successfully, extracting..."
            unzip -o /tmp/oneagent.zip -d /
            rm /tmp/oneagent.zip
            
            # Set connection point
            export DT_CONNECTION_POINT="https://${DT_TENANT}.live.dynatrace.com:443"
            
            echo "Starting Java with Dynatrace agent..."
            exec java -agentpath:/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so -jar /app/app.jar
        else
            echo "ERROR: Downloaded file is not a valid ZIP. Response code: $HTTP_CODE"
            echo "Content (first 200 chars):"
            head -c 200 /tmp/oneagent.zip
            echo -e "\n\nStarting without Dynatrace agent..."
            rm /tmp/oneagent.zip
            exec java -jar /app/app.jar
        fi
    else
        echo "ERROR: Failed to download OneAgent. HTTP code: $HTTP_CODE"
        [ -f /tmp/oneagent.zip ] && head -c 200 /tmp/oneagent.zip && rm /tmp/oneagent.zip
        echo -e "\n\nStarting without Dynatrace agent..."
        exec java -jar /app/app.jar
    fi
else
    echo "Dynatrace not configured, starting without agent..."
    exec java -jar /app/app.jar
fi
