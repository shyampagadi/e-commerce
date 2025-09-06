{
  // =============================================================================
  // GRAFANA DASHBOARD CONFIGURATION FOR E-COMMERCE FOUNDATION INFRASTRUCTURE
  // =============================================================================
  // This JSON file defines a comprehensive Grafana dashboard for monitoring
  // the e-commerce foundation infrastructure project. It provides real-time
  // visualization of cluster health, resource usage, and application metrics.
  // =============================================================================
  
  "dashboard": {
    // =============================================================================
    // DASHBOARD METADATA SECTION
    // =============================================================================
    // Contains basic information about the dashboard including identification,
    // display properties, and organizational metadata.
    // =============================================================================
    
    "id": null,
    // Purpose: Specifies the dashboard ID (null for new dashboards)
    // Why needed: Grafana uses this ID for dashboard identification and management
    // Impact: null indicates this is a new dashboard that will get an auto-generated ID
    // Value: null allows Grafana to assign a unique ID when imported
    
    "title": "E-commerce Foundation Infrastructure Dashboard",
    // Purpose: Specifies the human-readable name of the dashboard
    // Why needed: Identifies the dashboard in Grafana's dashboard list
    // Impact: This title will appear in the dashboard browser and navigation
    // Value: Descriptive name indicating this monitors the e-commerce foundation
    
    "tags": ["ecommerce", "kubernetes", "foundation"],
    // Purpose: Provides categorization and filtering tags for the dashboard
    // Why needed: Enables dashboard organization and discovery in Grafana
    // Impact: Dashboard can be filtered by these tags in the dashboard browser
    // Tags: "ecommerce" (project type), "kubernetes" (platform), "foundation" (tier)
    
    "style": "dark",
    // Purpose: Specifies the visual theme for the dashboard
    // Why needed: Provides consistent visual appearance and reduces eye strain
    // Impact: All panels will use the dark theme for better visibility
    // Theme: "dark" is preferred for monitoring environments and reduces glare
    
    "timezone": "browser",
    // Purpose: Specifies the timezone for time-based queries and displays
    // Why needed: Ensures time values are displayed in the user's local timezone
    // Impact: All time-based data will be shown in the browser's timezone
    // Value: "browser" automatically uses the user's system timezone
    
    "panels": [
      // =============================================================================
      // DASHBOARD PANELS SECTION
      // =============================================================================
      // Defines the individual monitoring panels that make up the dashboard.
      // Each panel displays specific metrics and provides different visualization types.
      // =============================================================================
      
      {
        // =============================================================================
        // PANEL 1: CLUSTER OVERVIEW
        // =============================================================================
        // Displays the overall health status of the Kubernetes cluster nodes.
        // This is a critical metric for understanding cluster availability.
        // =============================================================================
        
        "id": 1,
        // Purpose: Unique identifier for this panel within the dashboard
        // Why needed: Enables panel management and reference in Grafana
        // Impact: Panel can be referenced and modified using this ID
        // Value: 1 is the first panel in the dashboard
        
        "title": "Cluster Overview",
        // Purpose: Human-readable title for the panel
        // Why needed: Identifies the panel's purpose and content
        // Impact: Title appears at the top of the panel
        // Value: Descriptive name indicating cluster health monitoring
        
        "type": "stat",
        // Purpose: Specifies the visualization type for the panel
        // Why needed: Determines how the data is displayed to the user
        // Impact: Data will be shown as a single statistic value
        // Type: "stat" displays a single numeric value with color coding
        
        "targets": [
          // =============================================================================
          // PANEL TARGETS SECTION
          // =============================================================================
          // Defines the data sources and queries for this panel.
          // Each target specifies what data to fetch and how to display it.
          // =============================================================================
          
          {
            "expr": "up{job=\"kubernetes-nodes\"}",
            // Purpose: Prometheus query to check if Kubernetes nodes are up
            // Why needed: Provides real-time status of cluster node availability
            // Impact: Returns 1 for each healthy node, 0 for unhealthy nodes
            // Query: "up" metric with "kubernetes-nodes" job filter
            // Metric: "up" is a standard Prometheus metric indicating service health
            
            "legendFormat": "Nodes Up"
            // Purpose: Specifies how to label the data in the legend
            // Why needed: Provides clear identification of what the data represents
            // Impact: Legend will show "Nodes Up" for this data series
            // Format: Human-readable label for the metric
          }
        ],
        
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        // Purpose: Defines the panel's position and size in the dashboard grid
        // Why needed: Controls the layout and arrangement of panels
        // Impact: Panel will be 8 units high, 12 units wide, positioned at top-left
        // Grid: h=height, w=width, x=horizontal position, y=vertical position
        
        "fieldConfig": {
          // =============================================================================
          // PANEL FIELD CONFIGURATION
          // =============================================================================
          // Defines how the data should be displayed and formatted.
          // This includes color coding, thresholds, and display options.
          // =============================================================================
          
          "defaults": {
            // Purpose: Default configuration for all fields in this panel
            // Why needed: Provides consistent display formatting across the panel
            // Impact: All data fields will use these default settings
            // Scope: Applies to all data series in the panel
            
            "color": {"mode": "thresholds"},
            // Purpose: Specifies how colors should be applied to the data
            // Why needed: Enables color-coded status indication based on values
            // Impact: Colors will change based on threshold values
            // Mode: "thresholds" means colors are determined by threshold ranges
            
            "thresholds": {
              // =============================================================================
              // COLOR THRESHOLDS CONFIGURATION
              // =============================================================================
              // Defines the value ranges and corresponding colors for status indication.
              // This provides immediate visual feedback on cluster health.
              // =============================================================================
              
              "steps": [
                // Purpose: Array of threshold steps defining color ranges
                // Why needed: Provides clear visual indication of health status
                // Impact: Different colors will be shown based on node count
                // Steps: Each step defines a value range and corresponding color
                
                {"color": "red", "value": 0},
                // Purpose: Red color for 0 nodes (cluster down)
                // Why needed: Indicates critical failure state
                // Impact: Red will be shown when no nodes are available
                // Value: 0 means no healthy nodes in the cluster
                
                {"color": "yellow", "value": 1},
                // Purpose: Yellow color for 1 node (degraded state)
                // Why needed: Indicates partial failure or single-node cluster
                // Impact: Yellow will be shown when only one node is available
                // Value: 1 means only one healthy node (not ideal for production)
                
                {"color": "green", "value": 2}
                // Purpose: Green color for 2+ nodes (healthy state)
                // Why needed: Indicates healthy multi-node cluster
                // Impact: Green will be shown when 2 or more nodes are available
                // Value: 2+ means healthy cluster with redundancy
              ]
            }
          }
        }
      },
      
      {
        // =============================================================================
        // PANEL 2: POD STATUS
        // =============================================================================
        // Displays the number of ready pods in the e-commerce namespace.
        // This indicates the health of the application components.
        // =============================================================================
        
        "id": 2,
        // Purpose: Unique identifier for this panel within the dashboard
        // Why needed: Enables panel management and reference in Grafana
        // Impact: Panel can be referenced and modified using this ID
        // Value: 2 is the second panel in the dashboard
        
        "title": "Pod Status",
        // Purpose: Human-readable title for the panel
        // Why needed: Identifies the panel's purpose and content
        // Impact: Title appears at the top of the panel
        // Value: Descriptive name indicating pod health monitoring
        
        "type": "stat",
        // Purpose: Specifies the visualization type for the panel
        // Why needed: Determines how the data is displayed to the user
        // Impact: Data will be shown as a single statistic value
        // Type: "stat" displays a single numeric value with color coding
        
        "targets": [
          // =============================================================================
          // PANEL TARGETS SECTION
          // =============================================================================
          // Defines the data sources and queries for this panel.
          // Each target specifies what data to fetch and how to display it.
          // =============================================================================
          
          {
            "expr": "kube_pod_status_ready{namespace=\"ecommerce\"}",
            // Purpose: Prometheus query to check ready pods in ecommerce namespace
            // Why needed: Provides real-time status of application pod availability
            // Impact: Returns 1 for each ready pod, 0 for not ready pods
            // Query: "kube_pod_status_ready" metric filtered by ecommerce namespace
            // Metric: "kube_pod_status_ready" indicates if pods are ready to serve traffic
            
            "legendFormat": "Pods Ready"
            // Purpose: Specifies how to label the data in the legend
            // Why needed: Provides clear identification of what the data represents
            // Impact: Legend will show "Pods Ready" for this data series
            // Format: Human-readable label for the metric
          }
        ],
        
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        // Purpose: Defines the panel's position and size in the dashboard grid
        // Why needed: Controls the layout and arrangement of panels
        // Impact: Panel will be 8 units high, 12 units wide, positioned at top-right
        // Grid: h=height, w=width, x=horizontal position, y=vertical position
        
        "fieldConfig": {
          // =============================================================================
          // PANEL FIELD CONFIGURATION
          // =============================================================================
          // Defines how the data should be displayed and formatted.
          // This includes color coding, thresholds, and display options.
          // =============================================================================
          
          "defaults": {
            // Purpose: Default configuration for all fields in this panel
            // Why needed: Provides consistent display formatting across the panel
            // Impact: All data fields will use these default settings
            // Scope: Applies to all data series in the panel
            
            "color": {"mode": "thresholds"},
            // Purpose: Specifies how colors should be applied to the data
            // Why needed: Enables color-coded status indication based on values
            // Impact: Colors will change based on threshold values
            // Mode: "thresholds" means colors are determined by threshold ranges
            
            "thresholds": {
              // =============================================================================
              // COLOR THRESHOLDS CONFIGURATION
              // =============================================================================
              // Defines the value ranges and corresponding colors for status indication.
              // This provides immediate visual feedback on pod health.
              // =============================================================================
              
              "steps": [
                // Purpose: Array of threshold steps defining color ranges
                // Why needed: Provides clear visual indication of pod health status
                // Impact: Different colors will be shown based on ready pod count
                // Steps: Each step defines a value range and corresponding color
                
                {"color": "red", "value": 0},
                // Purpose: Red color for 0 ready pods (application down)
                // Why needed: Indicates critical failure state
                // Impact: Red will be shown when no pods are ready
                // Value: 0 means no ready pods (application unavailable)
                
                {"color": "yellow", "value": 1},
                // Purpose: Yellow color for 1 ready pod (degraded state)
                // Why needed: Indicates partial failure or single pod running
                // Impact: Yellow will be shown when only one pod is ready
                // Value: 1 means only one ready pod (not ideal for high availability)
                
                {"color": "green", "value": 2}
                // Purpose: Green color for 2+ ready pods (healthy state)
                // Why needed: Indicates healthy multi-pod deployment
                // Impact: Green will be shown when 2 or more pods are ready
                // Value: 2+ means healthy application with redundancy
              ]
            }
          }
        }
      },
      
      {
        // =============================================================================
        // PANEL 3: CPU USAGE
        // =============================================================================
        // Displays CPU usage percentage over time for cluster nodes.
        // This helps identify performance bottlenecks and resource constraints.
        // =============================================================================
        
        "id": 3,
        // Purpose: Unique identifier for this panel within the dashboard
        // Why needed: Enables panel management and reference in Grafana
        // Impact: Panel can be referenced and modified using this ID
        // Value: 3 is the third panel in the dashboard
        
        "title": "CPU Usage",
        // Purpose: Human-readable title for the panel
        // Why needed: Identifies the panel's purpose and content
        // Impact: Title appears at the top of the panel
        // Value: Descriptive name indicating CPU monitoring
        
        "type": "timeseries",
        // Purpose: Specifies the visualization type for the panel
        // Why needed: Determines how the data is displayed to the user
        // Impact: Data will be shown as a time series graph
        // Type: "timeseries" displays data points over time with lines/curves
        
        "targets": [
          // =============================================================================
          // PANEL TARGETS SECTION
          // =============================================================================
          // Defines the data sources and queries for this panel.
          // Each target specifies what data to fetch and how to display it.
          // =============================================================================
          
          {
            "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            // Purpose: Prometheus query to calculate CPU usage percentage
            // Why needed: Provides real-time CPU utilization monitoring
            // Impact: Returns CPU usage as a percentage (0-100%)
            // Query: Calculates CPU usage by subtracting idle time from 100%
            // Formula: 100 - (idle_cpu_rate * 100) = cpu_usage_percentage
            // Rate: "irate" calculates per-second rate over 5-minute window
            // Mode: "idle" represents CPU time spent in idle state
            
            "legendFormat": "CPU Usage %"
            // Purpose: Specifies how to label the data in the legend
            // Why needed: Provides clear identification of what the data represents
            // Impact: Legend will show "CPU Usage %" for this data series
            // Format: Human-readable label with percentage indicator
          }
        ],
        
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
        // Purpose: Defines the panel's position and size in the dashboard grid
        // Why needed: Controls the layout and arrangement of panels
        // Impact: Panel will be 8 units high, 12 units wide, positioned at middle-left
        // Grid: h=height, w=width, x=horizontal position, y=vertical position
        
        "fieldConfig": {
          // =============================================================================
          // PANEL FIELD CONFIGURATION
          // =============================================================================
          // Defines how the data should be displayed and formatted.
          // This includes units, ranges, and display options.
          // =============================================================================
          
          "defaults": {
            // Purpose: Default configuration for all fields in this panel
            // Why needed: Provides consistent display formatting across the panel
            // Impact: All data fields will use these default settings
            // Scope: Applies to all data series in the panel
            
            "unit": "percent",
            // Purpose: Specifies the unit of measurement for the data
            // Why needed: Enables proper formatting and display of percentage values
            // Impact: Values will be displayed with % symbol and proper scaling
            // Unit: "percent" formats values as percentages (0-100%)
            
            "min": 0,
            // Purpose: Sets the minimum value for the Y-axis
            // Why needed: Ensures consistent scale and prevents negative values
            // Impact: Y-axis will start at 0% CPU usage
            // Value: 0 represents no CPU usage
            
            "max": 100
            // Purpose: Sets the maximum value for the Y-axis
            // Why needed: Ensures consistent scale and shows full percentage range
            // Impact: Y-axis will end at 100% CPU usage
            // Value: 100 represents maximum CPU usage
          }
        }
      },
      
      {
        // =============================================================================
        // PANEL 4: MEMORY USAGE
        // =============================================================================
        // Displays memory usage percentage over time for cluster nodes.
        // This helps identify memory pressure and potential out-of-memory issues.
        // =============================================================================
        
        "id": 4,
        // Purpose: Unique identifier for this panel within the dashboard
        // Why needed: Enables panel management and reference in Grafana
        // Impact: Panel can be referenced and modified using this ID
        // Value: 4 is the fourth panel in the dashboard
        
        "title": "Memory Usage",
        // Purpose: Human-readable title for the panel
        // Why needed: Identifies the panel's purpose and content
        // Impact: Title appears at the top of the panel
        // Value: Descriptive name indicating memory monitoring
        
        "type": "timeseries",
        // Purpose: Specifies the visualization type for the panel
        // Why needed: Determines how the data is displayed to the user
        // Impact: Data will be shown as a time series graph
        // Type: "timeseries" displays data points over time with lines/curves
        
        "targets": [
          // =============================================================================
          // PANEL TARGETS SECTION
          // =============================================================================
          // Defines the data sources and queries for this panel.
          // Each target specifies what data to fetch and how to display it.
          // =============================================================================
          
          {
            "expr": "100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100)",
            // Purpose: Prometheus query to calculate memory usage percentage
            // Why needed: Provides real-time memory utilization monitoring
            // Impact: Returns memory usage as a percentage (0-100%)
            // Query: Calculates memory usage by comparing available to total memory
            // Formula: 100 - ((available_memory / total_memory) * 100) = memory_usage_percentage
            // Available: "node_memory_MemAvailable_bytes" represents available memory
            // Total: "node_memory_MemTotal_bytes" represents total system memory
            
            "legendFormat": "Memory Usage %"
            // Purpose: Specifies how to label the data in the legend
            // Why needed: Provides clear identification of what the data represents
            // Impact: Legend will show "Memory Usage %" for this data series
            // Format: Human-readable label with percentage indicator
          }
        ],
        
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8},
        // Purpose: Defines the panel's position and size in the dashboard grid
        // Why needed: Controls the layout and arrangement of panels
        // Impact: Panel will be 8 units high, 12 units wide, positioned at middle-right
        // Grid: h=height, w=width, x=horizontal position, y=vertical position
        
        "fieldConfig": {
          // =============================================================================
          // PANEL FIELD CONFIGURATION
          // =============================================================================
          // Defines how the data should be displayed and formatted.
          // This includes units, ranges, and display options.
          // =============================================================================
          
          "defaults": {
            // Purpose: Default configuration for all fields in this panel
            // Why needed: Provides consistent display formatting across the panel
            // Impact: All data fields will use these default settings
            // Scope: Applies to all data series in the panel
            
            "unit": "percent",
            // Purpose: Specifies the unit of measurement for the data
            // Why needed: Enables proper formatting and display of percentage values
            // Impact: Values will be displayed with % symbol and proper scaling
            // Unit: "percent" formats values as percentages (0-100%)
            
            "min": 0,
            // Purpose: Sets the minimum value for the Y-axis
            // Why needed: Ensures consistent scale and prevents negative values
            // Impact: Y-axis will start at 0% memory usage
            // Value: 0 represents no memory usage
            
            "max": 100
            // Purpose: Sets the maximum value for the Y-axis
            // Why needed: Ensures consistent scale and shows full percentage range
            // Impact: Y-axis will end at 100% memory usage
            // Value: 100 represents maximum memory usage
          }
        }
      },
      
      {
        // =============================================================================
        // PANEL 5: DISK USAGE
        // =============================================================================
        // Displays disk usage percentage over time for cluster nodes.
        // This helps identify storage capacity issues and disk space problems.
        // =============================================================================
        
        "id": 5,
        // Purpose: Unique identifier for this panel within the dashboard
        // Why needed: Enables panel management and reference in Grafana
        // Impact: Panel can be referenced and modified using this ID
        // Value: 5 is the fifth panel in the dashboard
        
        "title": "Disk Usage",
        // Purpose: Human-readable title for the panel
        // Why needed: Identifies the panel's purpose and content
        // Impact: Title appears at the top of the panel
        // Value: Descriptive name indicating disk monitoring
        
        "type": "timeseries",
        // Purpose: Specifies the visualization type for the panel
        // Why needed: Determines how the data is displayed to the user
        // Impact: Data will be shown as a time series graph
        // Type: "timeseries" displays data points over time with lines/curves
        
        "targets": [
          // =============================================================================
          // PANEL TARGETS SECTION
          // =============================================================================
          // Defines the data sources and queries for this panel.
          // Each target specifies what data to fetch and how to display it.
          // =============================================================================
          
          {
            "expr": "100 - ((node_filesystem_avail_bytes{mountpoint=\"/\"} / node_filesystem_size_bytes{mountpoint=\"/\"}) * 100)",
            // Purpose: Prometheus query to calculate disk usage percentage
            // Why needed: Provides real-time disk utilization monitoring
            // Impact: Returns disk usage as a percentage (0-100%)
            // Query: Calculates disk usage by comparing available to total disk space
            // Formula: 100 - ((available_space / total_space) * 100) = disk_usage_percentage
            // Available: "node_filesystem_avail_bytes" represents available disk space
            // Total: "node_filesystem_size_bytes" represents total disk space
            // Mountpoint: "/" filters for root filesystem only
            
            "legendFormat": "Disk Usage %"
            // Purpose: Specifies how to label the data in the legend
            // Why needed: Provides clear identification of what the data represents
            // Impact: Legend will show "Disk Usage %" for this data series
            // Format: Human-readable label with percentage indicator
          }
        ],
        
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 16},
        // Purpose: Defines the panel's position and size in the dashboard grid
        // Why needed: Controls the layout and arrangement of panels
        // Impact: Panel will be 8 units high, 12 units wide, positioned at bottom-left
        // Grid: h=height, w=width, x=horizontal position, y=vertical position
        
        "fieldConfig": {
          // =============================================================================
          // PANEL FIELD CONFIGURATION
          // =============================================================================
          // Defines how the data should be displayed and formatted.
          // This includes units, ranges, and display options.
          // =============================================================================
          
          "defaults": {
            // Purpose: Default configuration for all fields in this panel
            // Why needed: Provides consistent display formatting across the panel
            // Impact: All data fields will use these default settings
            // Scope: Applies to all data series in the panel
            
            "unit": "percent",
            // Purpose: Specifies the unit of measurement for the data
            // Why needed: Enables proper formatting and display of percentage values
            // Impact: Values will be displayed with % symbol and proper scaling
            // Unit: "percent" formats values as percentages (0-100%)
            
            "min": 0,
            // Purpose: Sets the minimum value for the Y-axis
            // Why needed: Ensures consistent scale and prevents negative values
            // Impact: Y-axis will start at 0% disk usage
            // Value: 0 represents no disk usage
            
            "max": 100
            // Purpose: Sets the maximum value for the Y-axis
            // Why needed: Ensures consistent scale and shows full percentage range
            // Impact: Y-axis will end at 100% disk usage
            // Value: 100 represents maximum disk usage
          }
        }
      },
      
      {
        // =============================================================================
        // PANEL 6: NETWORK TRAFFIC
        // =============================================================================
        // Displays network traffic rates over time for cluster nodes.
        // This helps identify network bottlenecks and communication patterns.
        // =============================================================================
        
        "id": 6,
        // Purpose: Unique identifier for this panel within the dashboard
        // Why needed: Enables panel management and reference in Grafana
        // Impact: Panel can be referenced and modified using this ID
        // Value: 6 is the sixth panel in the dashboard
        
        "title": "Network Traffic",
        // Purpose: Human-readable title for the panel
        // Why needed: Identifies the panel's purpose and content
        // Impact: Title appears at the top of the panel
        // Value: Descriptive name indicating network monitoring
        
        "type": "timeseries",
        // Purpose: Specifies the visualization type for the panel
        // Why needed: Determines how the data is displayed to the user
        // Impact: Data will be shown as a time series graph
        // Type: "timeseries" displays data points over time with lines/curves
        
        "targets": [
          // =============================================================================
          // PANEL TARGETS SECTION
          // =============================================================================
          // Defines the data sources and queries for this panel.
          // Each target specifies what data to fetch and how to display it.
          // =============================================================================
          
          {
            "expr": "irate(node_network_receive_bytes_total[5m])",
            // Purpose: Prometheus query to calculate network receive rate
            // Why needed: Provides real-time monitoring of incoming network traffic
            // Impact: Returns bytes per second of received network data
            // Query: "irate" calculates per-second rate of received bytes
            // Metric: "node_network_receive_bytes_total" represents total received bytes
            // Rate: "irate" calculates instantaneous rate over 5-minute window
            
            "legendFormat": "Receive {{device}}"
            // Purpose: Specifies how to label the data in the legend
            // Why needed: Provides clear identification of what the data represents
            // Impact: Legend will show "Receive <device_name>" for each network device
            // Format: Template with {{device}} placeholder for device name
          },
          
          {
            "expr": "irate(node_network_transmit_bytes_total[5m])",
            // Purpose: Prometheus query to calculate network transmit rate
            // Why needed: Provides real-time monitoring of outgoing network traffic
            // Impact: Returns bytes per second of transmitted network data
            // Query: "irate" calculates per-second rate of transmitted bytes
            // Metric: "node_network_transmit_bytes_total" represents total transmitted bytes
            // Rate: "irate" calculates instantaneous rate over 5-minute window
            
            "legendFormat": "Transmit {{device}}"
            // Purpose: Specifies how to label the data in the legend
            // Why needed: Provides clear identification of what the data represents
            // Impact: Legend will show "Transmit <device_name>" for each network device
            // Format: Template with {{device}} placeholder for device name
          }
        ],
        
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 16},
        // Purpose: Defines the panel's position and size in the dashboard grid
        // Why needed: Controls the layout and arrangement of panels
        // Impact: Panel will be 8 units high, 12 units wide, positioned at bottom-right
        // Grid: h=height, w=width, x=horizontal position, y=vertical position
        
        "fieldConfig": {
          // =============================================================================
          // PANEL FIELD CONFIGURATION
          // =============================================================================
          // Defines how the data should be displayed and formatted.
          // This includes units, ranges, and display options.
          // =============================================================================
          
          "defaults": {
            // Purpose: Default configuration for all fields in this panel
            // Why needed: Provides consistent display formatting across the panel
            // Impact: All data fields will use these default settings
            // Scope: Applies to all data series in the panel
            
            "unit": "Bps"
            // Purpose: Specifies the unit of measurement for the data
            // Why needed: Enables proper formatting and display of bytes per second
            // Impact: Values will be displayed with Bps suffix and proper scaling
            // Unit: "Bps" formats values as bytes per second with appropriate prefixes
          }
        }
      }
    ],
    
    "time": {
      // =============================================================================
      // DASHBOARD TIME RANGE CONFIGURATION
      // =============================================================================
      // Defines the default time range for the dashboard when it loads.
      // This affects all time-based queries and visualizations.
      // =============================================================================
      
      "from": "now-1h",
      // Purpose: Specifies the start time for the dashboard's time range
      // Why needed: Determines how far back in time to fetch data
      // Impact: Dashboard will show data from 1 hour ago to now
      // Value: "now-1h" means 1 hour before the current time
      // Format: Relative time format for dynamic time ranges
      
      "to": "now"
      // Purpose: Specifies the end time for the dashboard's time range
      // Why needed: Determines the current time boundary for data display
      // Impact: Dashboard will show data up to the current time
      // Value: "now" means the current time
      // Format: Relative time format for dynamic time ranges
    },
    
    "refresh": "30s"
    // Purpose: Specifies how often the dashboard should refresh its data
    // Why needed: Ensures dashboard shows current data without manual refresh
    // Impact: Dashboard will automatically refresh every 30 seconds
    // Value: "30s" means refresh every 30 seconds
    // Format: Time duration format for automatic refresh intervals
  }
}
