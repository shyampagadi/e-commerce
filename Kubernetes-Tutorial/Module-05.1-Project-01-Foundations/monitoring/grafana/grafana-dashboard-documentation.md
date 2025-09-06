# 📊 **Grafana Dashboard Documentation**
## *E-commerce Foundation Infrastructure Dashboard*

**File**: `grafana-dashboard.json`  
**Purpose**: Comprehensive monitoring dashboard for e-commerce foundation infrastructure  
**Version**: 1.0  
**Last Updated**: $(date)  

---

## 🎯 **Dashboard Overview**

This Grafana dashboard provides real-time monitoring and visualization of the e-commerce foundation infrastructure. It displays critical metrics including cluster health, resource usage, and application status.

---

## 📋 **Dashboard Configuration**

### **Basic Settings**

| Setting | Value | Purpose |
|---------|-------|---------|
| **Title** | "E-commerce Foundation Infrastructure Dashboard" | Identifies the dashboard in Grafana |
| **Theme** | "dark" | Provides better visibility for monitoring environments |
| **Timezone** | "browser" | Uses user's local timezone for time displays |
| **Refresh** | "30s" | Automatically refreshes data every 30 seconds |
| **Time Range** | "now-1h" to "now" | Shows data from the last hour |

### **Tags**
- `ecommerce` - Project type identifier
- `kubernetes` - Platform identifier  
- `foundation` - Infrastructure tier identifier

---

## 📊 **Panel Descriptions**

### **Panel 1: Cluster Overview**
- **Type**: Stat Panel
- **Purpose**: Displays the number of healthy Kubernetes nodes
- **Query**: `up{job="kubernetes-nodes"}`
- **Color Coding**:
  - 🔴 Red: 0 nodes (cluster down)
  - 🟡 Yellow: 1 node (degraded state)
  - 🟢 Green: 2+ nodes (healthy state)
- **Position**: Top-left (8x12 grid)

### **Panel 2: Pod Status**
- **Type**: Stat Panel
- **Purpose**: Displays the number of ready pods in ecommerce namespace
- **Query**: `kube_pod_status_ready{namespace="ecommerce"}`
- **Color Coding**:
  - 🔴 Red: 0 ready pods (application down)
  - 🟡 Yellow: 1 ready pod (degraded state)
  - 🟢 Green: 2+ ready pods (healthy state)
- **Position**: Top-right (8x12 grid)

### **Panel 3: CPU Usage**
- **Type**: Time Series Panel
- **Purpose**: Displays CPU usage percentage over time
- **Query**: `100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
- **Unit**: Percentage (0-100%)
- **Y-Axis Range**: 0-100%
- **Position**: Middle-left (8x12 grid)

### **Panel 4: Memory Usage**
- **Type**: Time Series Panel
- **Purpose**: Displays memory usage percentage over time
- **Query**: `100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100)`
- **Unit**: Percentage (0-100%)
- **Y-Axis Range**: 0-100%
- **Position**: Middle-right (8x12 grid)

### **Panel 5: Disk Usage**
- **Type**: Time Series Panel
- **Purpose**: Displays disk usage percentage over time
- **Query**: `100 - ((node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100)`
- **Unit**: Percentage (0-100%)
- **Y-Axis Range**: 0-100%
- **Position**: Bottom-left (8x12 grid)

### **Panel 6: Network Traffic**
- **Type**: Time Series Panel
- **Purpose**: Displays network traffic rates (receive/transmit)
- **Queries**:
  - Receive: `irate(node_network_receive_bytes_total[5m])`
  - Transmit: `irate(node_network_transmit_bytes_total[5m])`
- **Unit**: Bytes per second (Bps)
- **Legend**: Shows device names for each network interface
- **Position**: Bottom-right (8x12 grid)

---

## 🔧 **Technical Details**

### **Prometheus Queries Explained**

#### **Cluster Health Query**
```promql
up{job="kubernetes-nodes"}
```
- **Purpose**: Checks if Kubernetes nodes are responding
- **Returns**: 1 for each healthy node, 0 for unhealthy nodes
- **Filter**: Only includes nodes with job="kubernetes-nodes"

#### **Pod Status Query**
```promql
kube_pod_status_ready{namespace="ecommerce"}
```
- **Purpose**: Checks if pods in ecommerce namespace are ready
- **Returns**: 1 for each ready pod, 0 for not ready pods
- **Filter**: Only includes pods in the ecommerce namespace

#### **CPU Usage Query**
```promql
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```
- **Purpose**: Calculates CPU usage percentage
- **Method**: Subtracts idle CPU time from 100%
- **Rate**: Calculates per-second rate over 5-minute window
- **Aggregation**: Averages by instance (node)

#### **Memory Usage Query**
```promql
100 - ((node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100)
```
- **Purpose**: Calculates memory usage percentage
- **Method**: Compares available memory to total memory
- **Formula**: 100 - ((available / total) * 100)

#### **Disk Usage Query**
```promql
100 - ((node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100)
```
- **Purpose**: Calculates disk usage percentage for root filesystem
- **Method**: Compares available disk space to total disk space
- **Filter**: Only includes root filesystem (mountpoint="/")

#### **Network Traffic Queries**
```promql
# Receive traffic
irate(node_network_receive_bytes_total[5m])

# Transmit traffic  
irate(node_network_transmit_bytes_total[5m])
```
- **Purpose**: Calculates network traffic rates
- **Method**: Instantaneous rate of bytes over 5-minute window
- **Units**: Bytes per second
- **Legend**: Shows device names for each network interface

---

## 🎨 **Visual Configuration**

### **Color Schemes**
- **Red**: Critical issues (0 values)
- **Yellow**: Warning states (1 value)
- **Green**: Healthy states (2+ values)

### **Grid Layout**
- **Total Size**: 24x24 grid units
- **Panel Size**: 8x12 units each
- **Layout**: 2x3 grid arrangement
- **Responsive**: Panels adjust to screen size

### **Time Configuration**
- **Default Range**: Last 1 hour
- **Refresh Rate**: Every 30 seconds
- **Timezone**: Browser local time
- **Auto-refresh**: Enabled

---

## 🚀 **Usage Instructions**

### **Importing the Dashboard**
1. Open Grafana web interface
2. Navigate to "Dashboards" → "Import"
3. Upload the `grafana-dashboard.json` file
4. Configure data source (Prometheus)
5. Save and view the dashboard

### **Customizing the Dashboard**
1. Click on panel title to edit
2. Modify queries in the "Query" tab
3. Adjust visualization in the "Visualization" tab
4. Change colors and thresholds in "Field" tab
5. Save changes to update dashboard

### **Adding New Panels**
1. Click "Add panel" button
2. Select visualization type
3. Configure Prometheus query
4. Set appropriate units and thresholds
5. Position panel in grid layout

---

## 🔍 **Troubleshooting**

### **Common Issues**

#### **No Data Displayed**
- **Cause**: Prometheus not collecting metrics
- **Solution**: Check Prometheus targets and service discovery
- **Verification**: Run `kubectl get pods -n monitoring`

#### **Incorrect Values**
- **Cause**: Wrong query or metric names
- **Solution**: Verify Prometheus metrics using query browser
- **Verification**: Test queries in Prometheus web UI

#### **Missing Panels**
- **Cause**: Dashboard not properly imported
- **Solution**: Re-import dashboard JSON file
- **Verification**: Check dashboard JSON syntax

### **Performance Optimization**
- **Reduce Refresh Rate**: Change from 30s to 60s for better performance
- **Limit Time Range**: Use shorter time ranges for faster queries
- **Optimize Queries**: Use more specific filters to reduce data volume

---

## 📚 **Related Documentation**

- **Prometheus Configuration**: `../prometheus/prometheus.yml`
- **Grafana Deployment**: `../grafana-deployment.yaml`
- **Node Exporter**: `../node-exporter/node-exporter-deployment.yaml`
- **Operations Runbook**: `../../docs/05-operations-runbook.md`

---

**Document Status**: Complete  
**Review Date**: $(date + 30 days)  
**Next Update**: $(date + 7 days)  
**Approval Required**: Technical Lead, Monitoring Team
