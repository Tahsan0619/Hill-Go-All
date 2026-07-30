const HillGoData = {
  alerts: [
    { type: 'security', icon: 'fa-shield-halved', label: 'Security', description: 'Driver Verification Pending for ID #9283', status: 'CRITICAL', statusClass: 'critical', time: '2 mins ago' },
    { type: 'market', icon: 'fa-chart-line', label: 'Market', description: 'High Demand in New York Metropolitan Area', status: 'OPTIMIZATION', statusClass: 'optimization', time: '15 mins ago' },
    { type: 'system', icon: 'fa-server', label: 'System', description: 'Server cluster US-EAST-1 scaling initiated', status: 'STABLE', statusClass: 'stable', time: '1 hour ago' },
    { type: 'fleet', icon: 'fa-truck', label: 'Fleet', description: 'EV Charging Station Network: 100% Online', status: 'SUCCESS', statusClass: 'success', time: '3 hours ago' }
  ],

  users: [
    { id: 1, name: 'Sarah Mitchell', email: 'sarah.m@email.com', type: 'customer', status: 'active', joined: 'Oct 12, 2023', avatar: 'https://i.pravatar.cc/80?img=1', color: '#6366F1' },
    { id: 2, name: 'James Rodriguez', email: 'j.rodriguez@corp.io', type: 'partner', status: 'active', joined: 'Sep 28, 2023', avatar: 'https://i.pravatar.cc/80?img=3', color: '#F59E0B' },
    { id: 3, name: 'Emily Chen', email: 'emily.chen@gmail.com', type: 'customer', status: 'pending', joined: 'Oct 24, 2023', avatar: null, color: '#10B981' },
    { id: 4, name: 'Marcus Williams', email: 'm.williams@biz.net', type: 'partner', status: 'suspended', joined: 'Aug 15, 2023', avatar: 'https://i.pravatar.cc/80?img=8', color: '#EF4444' },
    { id: 5, name: 'Lisa Park', email: 'lisa.park@startup.co', type: 'customer', status: 'active', joined: 'Oct 20, 2023', avatar: null, color: '#8B5CF6' },
    { id: 6, name: 'David Kim', email: 'david.kim@enterprise.com', type: 'partner', status: 'active', joined: 'Jul 3, 2023', avatar: 'https://i.pravatar.cc/80?img=11', color: '#0047AB' }
  ],

  fleet: [
    { id: 'HG-77291-NYC', type: 'Tesla Model 3 (EV)', icon: 'fa-car', partner: 'Metro Fleet Logistics', date: 'Oct 24, 2023', status: 'Pending Review' },
    { id: 'HG-88120-CHI', type: 'Ford E-Transit Van', icon: 'fa-van-shuttle', partner: 'Apex Delivery Co.', date: 'Oct 25, 2023', status: 'Pending Review' },
    { id: 'HG-44590-LAX', type: 'Niu NQi Sport Scooter', icon: 'fa-motorcycle', partner: 'Swift Urban Partners', date: 'Oct 25, 2023', status: 'Pending Review' }
  ],

  clusters: [
    { name: 'Downtown Core', vehicles: 412, capacity: 88, color: '#0047AB' },
    { name: 'Airport Express', vehicles: 156, capacity: 92, color: '#F59E0B' },
    { name: 'Residential East', vehicles: 320, capacity: 45, color: '#10B981' },
    { name: 'Industrial Zone', vehicles: 94, capacity: 12, color: '#9CA3AF' }
  ],

  transactions: [
    { id: '#TRX-948102', service: 'HillGo Ride', serviceType: 'ride', icon: 'fa-car', amount: '$24.50', commission: '$3.68', commissionPct: '15%', status: 'completed', date: 'Oct 24, 2023', time: '14:22 PM' },
    { id: '#TRX-948103', service: 'HillGo Food', serviceType: 'food', icon: 'fa-utensils', amount: '$38.90', commission: '$5.84', commissionPct: '15%', status: 'completed', date: 'Oct 24, 2023', time: '13:45 PM' },
    { id: '#TRX-948104', service: 'HillGo Market', serviceType: 'market', icon: 'fa-store', amount: '$156.00', commission: '$23.40', commissionPct: '15%', status: 'processing', date: 'Oct 24, 2023', time: '12:30 PM' },
    { id: '#TRX-948105', service: 'HillGo Ride', serviceType: 'ride', icon: 'fa-car', amount: '$18.75', commission: '$2.81', commissionPct: '15%', status: 'completed', date: 'Oct 23, 2023', time: '22:10 PM' },
    { id: '#TRX-948106', service: 'HillGo Food', serviceType: 'food', icon: 'fa-utensils', amount: '$52.30', commission: '$7.85', commissionPct: '15%', status: 'failed', date: 'Oct 23, 2023', time: '19:55 PM' }
  ],

  healthItems: [
    { label: '12 Missing Images', icon: 'fa-image', color: 'red' },
    { label: '8 Poor Descriptions', icon: 'fa-align-left', color: 'orange' },
    { label: '94% Metadata Health', icon: 'fa-check-circle', color: 'green' }
  ],

  products: [
    { title: 'Organic Avocado Pack', sku: 'SKU-AVO-001', image: 'https://images.unsplash.com/photo-1523049673857-eb18f1d97966?w=300&h=200&fit=crop', badge: 'ACTIVE', badgeClass: 'active', stock: 142, stockStatus: 'Healthy', stockClass: 'healthy', actions: ['Edit', 'Manage'] },
    { title: 'Wireless Hub X1', sku: 'SKU-HUB-042', image: null, badge: 'DRAFT', badgeClass: 'draft', stock: 0, stockStatus: 'Urgent', stockClass: 'urgent', actions: ['Fix Content', 'Manage'], missing: true },
    { title: 'Premium Coffee Beans', sku: 'SKU-COF-018', image: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=300&h=200&fit=crop', badge: 'ACTIVE', badgeClass: 'active', stock: 28, stockStatus: 'Low Stock', stockClass: 'low', actions: ['Edit', 'Restock'] },
    { title: 'Eco Water Bottle', sku: 'SKU-BTL-007', image: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=300&h=200&fit=crop', badge: 'ACTIVE', badgeClass: 'active', stock: 310, stockStatus: 'Healthy', stockClass: 'healthy', actions: ['Edit', 'Manage'] }
  ],

  revenueData: {
    ride: { labels: ['D1','D5','D10','D15','D20','D25','Today'], bars: [42,55,48,62,58,70,65], line: [38,52,45,58,55,68,62] },
    food: { labels: ['D1','D5','D10','D15','D20','D25','Today'], bars: [30,38,42,35,48,52,45], line: [28,35,40,33,45,48,42] },
    marketplace: { labels: ['D1','D5','D10','D15','D20','D25','Today'], bars: [22,28,32,38,35,42,48], line: [20,25,30,35,33,40,45] }
  },

  searchPlaceholders: {
    overview: 'Search data points...',
    users: 'Search for users, orders, or partners...',
    fleet: 'Search fleet, vehicles, or drivers...',
    finance: 'Search transactions, IDs, or merchants...',
    content: 'Search marketplace, listings, or campaigns...',
    settings: 'Search settings...'
  },

  userRoles: {
    overview: 'System Manager',
    users: 'Super Administrator',
    fleet: 'Superuser',
    finance: 'Finance Lead',
    content: 'Super Administrator',
    settings: 'Super Administrator'
  }
};
