# Network Lab Setup Project

## 🎯 Project Overview
Build a comprehensive virtual network laboratory using GNS3 to simulate enterprise network environments for CCNA/CCNP preparation.

## 📋 Prerequisites
- **Software**: GNS3, VMware Workstation/VirtualBox
- **Hardware**: 8GB+ RAM, 100GB+ free disk space
- **Knowledge**: Basic networking concepts
- **Time**: 2-3 days setup, ongoing for labs

## 🛠️ Required Software and Images

### GNS3 Installation
```bash
# Ubuntu/Debian
wget https://github.com/GNS3/gns3-gui/releases/download/v2.2.46/GNS3-2.2.46-linux.AppImage
chmod +x GNS3-2.2.46-linux.AppImage
./GNS3-2.2.46-linux.AppImage

# Windows - Download from GNS3.com
# Install GNS3 GUI and VM
```

### Required Images
- **Cisco IOS**: c7200-adventerprisek9-mz.124-24.T5.bin
- **Cisco Switch**: c3745-adventerprisek9-mz.124-25d.bin
- **Linux**: Ubuntu Server 22.04 LTS
- **Windows**: Windows 10/11 (for testing)
- **pfSense**: For firewall simulation

## 🏗️ Lab Topology Design

### Core Infrastructure
```
Internet Cloud
     |
   pfSense
     |
Core-Switch-01 ---- Core-Switch-02
     |                    |
Distribution-SW-01   Distribution-SW-02
     |                    |
Access-SW-01        Access-SW-02
     |                    |
  End Devices        End Devices
```

### VLAN Structure
- **VLAN 10**: Management (192.168.10.0/24)
- **VLAN 20**: Sales Department (192.168.20.0/24)
- **VLAN 30**: IT Department (192.168.30.0/24)
- **VLAN 40**: Guest Network (192.168.40.0/24)
- **VLAN 99**: Native VLAN

## 📝 Step-by-Step Implementation

### Phase 1: Basic Network Setup

#### Step 1: Create GNS3 Project
1. Open GNS3
2. Create new project: "Enterprise-Network-Lab"
3. Configure project settings

#### Step 2: Add Network Devices
```gns3-topology
# Core Layer
- 2x Cisco 7200 Routers (Core-Router-01, Core-Router-02)
- 2x Cisco 3560 Switches (Core-Switch-01, Core-Switch-02)

# Distribution Layer  
- 2x Cisco 3560 Switches (Dist-Switch-01, Dist-Switch-02)

# Access Layer
- 4x Cisco 2960 Switches (Access-SW-01 to 04)

# Security
- 1x pfSense Firewall
- 1x Internet Cloud
```

#### Step 3: Configure Core Routers
```cisco-ios
! Core-Router-01 Configuration
Router>enable
Router#configure terminal
Router(config)#hostname Core-R1
Core-R1(config)#interface gigabitethernet0/0
Core-R1(config-if)#ip address 10.0.1.1 255.255.255.252
Core-R1(config-if)#no shutdown
Core-R1(config-if)#exit

! Enable OSPF
Core-R1(config)#router ospf 1
Core-R1(config-router)#network 10.0.0.0 0.0.255.255 area 0
Core-R1(config-router)#exit

! Configure HSRP for high availability
Core-R1(config)#interface vlan 10
Core-R1(config-if)#standby 1 ip 192.168.10.1
Core-R1(config-if)#standby 1 priority 110
Core-R1(config-if)#standby 1 preempt
```

### Phase 2: VLAN Configuration

#### Step 4: Configure VLANs on Core Switches
```cisco-ios
! Core-Switch-01 Configuration
Switch>enable
Switch#configure terminal
Switch(config)#hostname Core-SW1

! Create VLANs
Core-SW1(config)#vlan 10
Core-SW1(config-vlan)#name Management
Core-SW1(config-vlan)#vlan 20
Core-SW1(config-vlan)#name Sales
Core-SW1(config-vlan)#vlan 30
Core-SW1(config-vlan)#name IT
Core-SW1(config-vlan)#vlan 40
Core-SW1(config-vlan)#name Guest
Core-SW1(config-vlan)#vlan 99
Core-SW1(config-vlan)#name Native
Core-SW1(config-vlan)#exit

! Configure trunk links
Core-SW1(config)#interface range fastethernet0/1-2
Core-SW1(config-if-range)#switchport mode trunk
Core-SW1(config-if-range)#switchport trunk native vlan 99
Core-SW1(config-if-range)#switchport trunk allowed vlan 10,20,30,40,99
```

#### Step 5: Configure Distribution Switches
```cisco-ios
! Distribution-Switch-01
Dist-SW1(config)#vtp mode client
Dist-SW1(config)#vtp domain LAB-DOMAIN

! Configure inter-VLAN routing
Dist-SW1(config)#ip routing
Dist-SW1(config)#interface vlan 20
Dist-SW1(config-if)#ip address 192.168.20.254 255.255.255.0
Dist-SW1(config-if)#standby 1 ip 192.168.20.1
Dist-SW1(config-if)#standby 1 priority 110
```

### Phase 3: Access Layer and End Devices

#### Step 6: Configure Access Switches
```cisco-ios
! Access-Switch-01
Access-SW1(config)#vtp mode client
Access-SW1(config)#vtp domain LAB-DOMAIN

! Configure access ports
Access-SW1(config)#interface range fastethernet0/1-12
Access-SW1(config-if-range)#switchport mode access
Access-SW1(config-if-range)#switchport access vlan 20
Access-SW1(config-if-range)#spanning-tree portfast

! Configure trunk to distribution
Access-SW1(config)#interface fastethernet0/24
Access-SW1(config-if)#switchport mode trunk
Access-SW1(config-if)#switchport trunk native vlan 99
```

#### Step 7: Add and Configure End Devices
```bash
# Ubuntu Server Configuration
sudo nano /etc/netplan/01-netcfg.yaml

network:
  version: 2
  renderer: networkd
  ethernets:
    ens3:
      addresses:
        - 192.168.20.10/24
      gateway4: 192.168.20.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]

sudo netplan apply
```

### Phase 4: Advanced Services

#### Step 8: Configure DHCP
```cisco-ios
! Core Router DHCP Configuration
Core-R1(config)#ip dhcp excluded-address 192.168.20.1 192.168.20.10
Core-R1(config)#ip dhcp pool SALES-POOL
Core-R1(dhcp-config)#network 192.168.20.0 255.255.255.0
Core-R1(dhcp-config)#default-router 192.168.20.1
Core-R1(dhcp-config)#dns-server 8.8.8.8 8.8.4.4
Core-R1(dhcp-config)#lease 7
```

#### Step 9: Configure Security Features
```cisco-ios
! Port Security on Access Switches
Access-SW1(config)#interface range fastethernet0/1-12
Access-SW1(config-if-range)#switchport port-security
Access-SW1(config-if-range)#switchport port-security maximum 2
Access-SW1(config-if-range)#switchport port-security violation restrict
Access-SW1(config-if-range)#switchport port-security mac-address sticky

! Configure ACLs
Core-R1(config)#access-list 100 deny tcp 192.168.40.0 0.0.0.255 192.168.30.0 0.0.0.255
Core-R1(config)#access-list 100 permit ip any any
Core-R1(config)#interface vlan 40
Core-R1(config-if)#ip access-group 100 in
```

## 🧪 Lab Exercises

### Exercise 1: Basic Connectivity Test
**Objective**: Verify all devices can communicate within their VLANs

**Tasks**:
1. Ping between devices in same VLAN
2. Verify DHCP assignments
3. Test inter-VLAN routing
4. Document results

### Exercise 2: VLAN Troubleshooting
**Objective**: Practice VLAN troubleshooting skills

**Scenarios**:
1. Break VLAN configuration
2. Misconfigure trunk links
3. Create spanning-tree loops
4. Troubleshoot and fix issues

### Exercise 3: Routing Protocol Configuration
**Objective**: Implement and test OSPF routing

**Tasks**:
1. Configure OSPF on all routers
2. Verify neighbor relationships
3. Test route convergence
4. Implement route summarization

### Exercise 4: Network Security Implementation
**Objective**: Secure the network infrastructure

**Tasks**:
1. Configure port security
2. Implement ACLs
3. Set up 802.1X authentication
4. Configure DHCP snooping

## 📊 Network Monitoring and Documentation

### Monitoring Tools Setup
```bash
# Install monitoring tools on Linux server
sudo apt update
sudo apt install -y nagios3 cacti snmp snmp-mibs-downloader

# Configure SNMP on network devices
Core-R1(config)#snmp-server community public RO
Core-R1(config)#snmp-server location "Lab Core"
Core-R1(config)#snmp-server contact "lab-admin@company.com"
```

### Documentation Templates
- **Network Diagram**: Visual topology with IP addressing
- **Configuration Backup**: Save all device configurations
- **Change Log**: Track all modifications
- **Troubleshooting Guide**: Common issues and solutions

## 🎯 Advanced Lab Scenarios

### Scenario 1: Branch Office Connectivity
- Add WAN link simulation
- Configure VPN tunnels
- Implement QoS policies
- Test failover scenarios

### Scenario 2: Wireless Integration
- Add wireless controller
- Configure SSIDs and VLANs
- Implement wireless security
- Test roaming scenarios

### Scenario 3: Data Center Simulation
- Add server farm
- Configure load balancing
- Implement redundancy
- Test disaster recovery

## 📋 Maintenance and Updates

### Regular Tasks
- **Weekly**: Backup configurations
- **Monthly**: Update software images
- **Quarterly**: Review and update documentation
- **Annually**: Hardware refresh planning

### Best Practices
1. Always backup before changes
2. Test in isolated environment first
3. Document all configurations
4. Use version control for scripts
5. Regular security updates

## 🔗 Additional Resources

- [GNS3 Academy](https://gns3.com/academy)
- [Cisco DevNet Labs](https://developer.cisco.com/labs/)
- [Network Automation Scripts](https://github.com/ktbyers/netmiko)
- [CCNA Lab Guide](https://www.flackbox.com/cisco-ccna-lab-guide)

## 📈 Learning Outcomes

By completing this project, you will have:
- Built a enterprise-grade network simulation
- Configured VLANs, routing, and switching
- Implemented network security measures
- Gained hands-on troubleshooting experience
- Created documentation and monitoring systems
- Prepared for CCNA/CCNP certification exams