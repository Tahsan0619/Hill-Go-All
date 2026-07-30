/**
 * HillGo Admin — seed data (Bangladesh ops, BDT).
 * Replace with API responses later; keep shapes stable.
 */
window.HillGoSeed = (() => {
  const divisions = [
    {
      id: 'dhaka',
      name: 'Dhaka',
      zone: 'Central Hub',
      districts: [
        'Dhaka', 'Faridpur', 'Gazipur', 'Gopalganj', 'Kishoreganj', 'Madaripur',
        'Manikganj', 'Munshiganj', 'Narayanganj', 'Narsingdi', 'Rajbari', 'Shariatpur', 'Tangail',
      ],
    },
    {
      id: 'chattogram',
      name: 'Chattogram',
      zone: 'Coastal Hub',
      districts: [
        'Bandarban', 'Brahmanbaria', 'Chandpur', 'Chattogram', 'Cumilla', "Cox's Bazar",
        'Feni', 'Khagrachhari', 'Lakshmipur', 'Noakhali', 'Rangamati',
      ],
    },
    {
      id: 'rajshahi',
      name: 'Rajshahi',
      zone: 'Northwest',
      districts: [
        'Bogura', 'Chapainawabganj', 'Joypurhat', 'Naogaon', 'Natore', 'Pabna', 'Rajshahi', 'Sirajganj',
      ],
    },
    {
      id: 'khulna',
      name: 'Khulna',
      zone: 'Southwest',
      districts: [
        'Bagerhat', 'Chuadanga', 'Jashore', 'Jhenaidah', 'Khulna', 'Kushtia', 'Magura', 'Meherpur', 'Narail', 'Satkhira',
      ],
    },
    {
      id: 'barishal',
      name: 'Barishal',
      zone: 'Southern',
      districts: ['Barguna', 'Barishal', 'Bhola', 'Jhalokathi', 'Patuakhali', 'Pirojpur'],
    },
    {
      id: 'sylhet',
      name: 'Sylhet',
      zone: 'Northeast',
      districts: ['Habiganj', 'Moulvibazar', 'Sunamganj', 'Sylhet'],
    },
    {
      id: 'rangpur',
      name: 'Rangpur',
      zone: 'Northern Zone',
      districts: [
        'Dinajpur', 'Gaibandha', 'Kurigram', 'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Rangpur', 'Thakurgaon',
      ],
    },
    {
      id: 'mymensingh',
      name: 'Mymensingh',
      zone: 'North-Central',
      districts: ['Jamalpur', 'Mymensingh', 'Netrokona', 'Sherpur'],
    },
  ];

  /** Default open map: Dhaka all open, Chattogram partial, Khulna all open, Barishal partial, rest closed */
  const closedDefaults = new Set([
    'Gazipur', // emergency maintenance sample
    'Bandarban', 'Khagrachhari', 'Rangamati',
    'Bogura', 'Chapainawabganj', 'Joypurhat', 'Naogaon', 'Natore', 'Pabna', 'Rajshahi', 'Sirajganj',
    'Barguna', 'Pirojpur',
    'Habiganj', 'Moulvibazar', 'Sunamganj', 'Sylhet',
    'Dinajpur', 'Gaibandha', 'Kurigram', 'Lalmonirhat', 'Nilphamari', 'Panchagarh', 'Rangpur', 'Thakurgaon',
    'Jamalpur', 'Mymensingh', 'Netrokona', 'Sherpur',
  ]);

  const regionDistricts = [];
  divisions.forEach((div) => {
    div.districts.forEach((name) => {
      const closed = closedDefaults.has(name);
      regionDistricts.push({
        id: `${div.id}__${name.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`,
        divisionId: div.id,
        divisionName: div.name,
        name,
        status: closed ? 'closed' : 'open',
        openedAt: closed ? null : '2024-01-15T09:00',
        allowCustomer: !closed,
        allowRider: !closed,
        allowMerchant: !closed,
        allowCourier: !closed && name !== 'Gazipur',
        note: name === 'Gazipur' ? 'Emergency maintenance by Admin Kabir' : '',
        updatedAt: new Date().toISOString(),
        updatedBy: 'Admin User',
      });
    });
  });

  const customers = [
    { id: 'HG-88021', name: 'Ariful Salman', phone: '+880 1712-345678', email: 'ariful.salman@email.com', district: 'Dhaka', status: 'active', tier: 'Gold', wallet: 1240.5, loyaltyPoints: 12450, orders: 142, rating: 4.8, joined: '2024-03-12' },
    { id: 'HG-88022', name: 'Nadia Tabassum', phone: '+880 1811-223344', email: 'nadia.t@email.com', district: 'Chattogram', status: 'active', tier: 'Silver', wallet: 890.0, loyaltyPoints: 4200, orders: 58, rating: 4.6, joined: '2024-06-01' },
    { id: 'HG-88023', name: 'Mahir Ahmed', phone: '+880 1912-556677', email: 'mahir.a@email.com', district: 'Sylhet', status: 'active', tier: 'Bronze', wallet: 320.25, loyaltyPoints: 1100, orders: 22, rating: 4.3, joined: '2025-01-20' },
    { id: 'HG-88024', name: 'Farzana Zaman', phone: '+880 1613-998877', email: 'farzana.z@email.com', district: 'Khulna', status: 'active', tier: 'Gold', wallet: 2100.0, loyaltyPoints: 9800, orders: 97, rating: 4.9, joined: '2023-11-08' },
    { id: 'HG-88025', name: 'Sabbir Khan', phone: '+880 1715-443322', email: 'sabbir.k@email.com', district: 'Dhaka', status: 'suspended', tier: 'Silver', wallet: 45.0, loyaltyPoints: 200, orders: 8, rating: 3.2, joined: '2025-04-02' },
    { id: 'HG-88026', name: 'Sumaiya Akhter', phone: '+880 1718-667788', email: 'sumaiya.a@email.com', district: 'Narayanganj', status: 'active', tier: 'Platinum', wallet: 5400.0, loyaltyPoints: 22000, orders: 310, rating: 4.95, joined: '2023-05-14' },
    { id: 'HG-88027', name: 'Mofizur Rahman', phone: '+880 1819-112233', email: 'mofizur.r@email.com', district: 'Gazipur', status: 'suspended', tier: 'Platinum', wallet: 0, loyaltyPoints: 15000, orders: 180, rating: 4.1, joined: '2023-08-22' },
    { id: 'HG-88028', name: 'Nasreen Jahan', phone: '+880 1711-998800', email: 'nasreen.j@email.com', district: 'Dhaka', status: 'active', tier: 'Gold', wallet: 1560.0, loyaltyPoints: 7600, orders: 88, rating: 4.7, joined: '2024-09-10' },
  ];

  const rides = [
    { id: 'RID-8821', customerId: 'HG-88021', customer: 'Ariful Salman', rider: 'Karim Hossain', pickup: 'Gulshan 1', drop: 'Motijheel', fare: 450, status: 'completed', date: '2026-07-30', distanceKm: 12.4 },
    { id: 'RID-8820', customerId: 'HG-88022', customer: 'Nadia Tabassum', rider: 'Rafiq Islam', pickup: 'Dhanmondi 27', drop: 'Banani', fare: 280, status: 'completed', date: '2026-07-30', distanceKm: 7.2 },
    { id: 'RID-8819', customerId: 'HG-88028', customer: 'Nasreen Jahan', rider: 'Sultana Begum', pickup: 'Uttara Sec 7', drop: 'Airport', fare: 320, status: 'in_progress', date: '2026-07-31', distanceKm: 8.1 },
    { id: 'RID-8818', customerId: 'HG-88024', customer: 'Farzana Zaman', rider: 'Tanvir Ahmed', pickup: 'Khulna City', drop: 'Sonadanga', fare: 190, status: 'cancelled', date: '2026-07-29', distanceKm: 4.5 },
    { id: 'RID-8817', customerId: 'HG-88026', customer: 'Sumaiya Akhter', rider: 'Abdur Rahim', pickup: 'Mirpur 10', drop: 'Gulshan 2', fare: 380, status: 'completed', date: '2026-07-29', distanceKm: 11.0 },
    { id: 'RID-8816', customerId: 'HG-88023', customer: 'Mahir Ahmed', rider: 'Sakib Hasan', pickup: 'Zindabazar', drop: 'Amberkhana', fare: 150, status: 'completed', date: '2026-07-28', distanceKm: 3.8 },
  ];

  const foodOrders = [
    { id: 'ORD-5542', restaurant: 'Kacchi Bhai', customer: 'Ariful Salman', total: 890, deliveryFee: 30, status: 'delivered', date: '2026-07-30', district: 'Dhaka' },
    { id: 'ORD-5541', restaurant: 'Pizza Hut', customer: 'Nadia Tabassum', total: 1250, deliveryFee: 40, status: 'on_the_way', date: '2026-07-31', district: 'Chattogram' },
    { id: 'ORD-5540', restaurant: 'Star Kabab', customer: 'Nasreen Jahan', total: 540, deliveryFee: 25, status: 'preparing', date: '2026-07-31', district: 'Dhaka' },
    { id: 'ORD-5539', restaurant: 'Chillox Cafe', customer: 'Sumaiya Akhter', total: 720, deliveryFee: 30, status: 'placed', date: '2026-07-31', district: 'Narayanganj' },
    { id: 'ORD-5538', restaurant: 'Kacchi Bhai', customer: 'Farzana Zaman', total: 1100, deliveryFee: 35, status: 'delivered', date: '2026-07-29', district: 'Khulna' },
  ];

  const customerParcels = [
    { id: 'CP-2105', type: 'Document', pickup: 'Gulshan', destination: 'Motijheel', weightKg: 0.5, distanceKm: 10, fare: 95, status: 'delivered', customer: 'Ariful Salman', date: '2026-07-30' },
    { id: 'CP-2104', type: 'Electronics', pickup: 'Banani', destination: 'Uttara', weightKg: 2.2, distanceKm: 14, fare: 180, status: 'in_transit', customer: 'Nadia Tabassum', date: '2026-07-31' },
    { id: 'CP-2103', type: 'Gift', pickup: 'Dhanmondi', destination: 'Mirpur', weightKg: 1.0, distanceKm: 9, fare: 120, status: 'picked_up', customer: 'Nasreen Jahan', date: '2026-07-31' },
    { id: 'CP-2102', type: 'Food Parcel', pickup: 'Bashundhara', destination: 'Badda', weightKg: 3.5, distanceKm: 6, fare: 140, status: 'booked', customer: 'Sumaiya Akhter', date: '2026-07-31' },
    { id: 'CP-2101', type: 'Document', pickup: 'Sylhet', destination: 'Dhaka', weightKg: 0.3, distanceKm: 240, fare: 450, status: 'cancelled', customer: 'Mahir Ahmed', date: '2026-07-28' },
  ];

  const riders = [
    { id: 'HG-RD-9921', name: 'Tanvir Ahmed', phone: '+880 1711-223344', vehicle: 'bike', plate: 'DHAKA-METRO-HA-11-1234', rating: 4.9, online: true, district: 'Dhaka', status: 'active', todayEarnings: 1850, tripsToday: 12 },
    { id: 'HG-RD-4521', name: 'Rakibul Islam', phone: '+880 1812-334455', vehicle: 'car', plate: 'DHAKA-METRO-GA-22-5678', rating: 4.7, online: true, district: 'Dhaka', status: 'active', todayEarnings: 3200, tripsToday: 8 },
    { id: 'HG-RD-1102', name: 'Sumon Miah', phone: '+880 1913-445566', vehicle: 'bike', plate: 'CTG-KA-33-9012', rating: 4.5, online: false, district: 'Chattogram', status: 'active', todayEarnings: 0, tripsToday: 0 },
    { id: 'HG-RD-8834', name: 'Farzana Akter', phone: '+880 1614-556677', vehicle: 'xl', plate: 'DHAKA-METRO-CHA-44-3456', rating: 4.8, online: true, district: 'Gazipur', status: 'active', todayEarnings: 4100, tripsToday: 6 },
    { id: 'HG-RD-2023', name: 'Abdur Rahim', phone: '+880 1715-667788', vehicle: 'bike', plate: 'KHL-KHA-55-7890', rating: 4.4, online: false, district: 'Khulna', status: 'suspended', todayEarnings: 0, tripsToday: 0 },
    { id: 'HG-RD-3340', name: 'Karim Hossain', phone: '+880 1716-778899', vehicle: 'bike', plate: 'DHAKA-METRO-GA-66-1122', rating: 4.6, online: true, district: 'Dhaka', status: 'active', todayEarnings: 1420, tripsToday: 9 },
    { id: 'HG-RD-3341', name: 'Sultana Begum', phone: '+880 1817-889900', vehicle: 'car', plate: 'DHAKA-METRO-HA-77-3344', rating: 4.85, online: true, district: 'Dhaka', status: 'active', todayEarnings: 2780, tripsToday: 7 },
  ];

  const riderKyc = [
    { id: 'KYC-R-01', riderId: 'HG-RD-9921', riderName: 'Tanvir Ahmed', docs: ["Driver's License", 'NID', 'Vehicle Registration', 'Rider Photo'], status: 'pending', priority: true, submitted: '2026-07-28', flagged: false },
    { id: 'KYC-R-02', riderId: 'HG-RD-1102', riderName: 'Sumon Miah', docs: ['NID', 'Token', 'Vehicle Registration'], status: 'action_required', priority: false, submitted: '2026-07-25', flagged: true },
    { id: 'KYC-R-03', riderId: 'HG-RD-8834', riderName: 'Farzana Akter', docs: ["Driver's License", 'NID', 'Blue Book', 'Rider Photo'], status: 'uploaded', priority: true, submitted: '2026-07-30', flagged: false },
    { id: 'KYC-R-04', riderId: 'HG-RD-2023', riderName: 'Abdur Rahim', docs: ['NID'], status: 'pending', priority: false, submitted: '2026-07-20', flagged: true },
    { id: 'KYC-R-05', riderId: 'HG-RD-4521', riderName: 'Rakibul Islam', docs: ["Driver's License", 'NID', 'Vehicle Registration', 'Rider Photo'], status: 'verified', priority: false, submitted: '2026-06-10', flagged: false },
  ];

  const trips = [
    { id: 'HG-98210', type: 'ride', riderId: 'HG-RD-9921', rider: 'Tanvir Ahmed', route: 'Gulshan → Motijheel', km: 12.4, earning: 450, payment: 'digital', surge: 1.0, status: 'completed', cod: 0, date: '2026-07-30' },
    { id: 'HG-98211', type: 'food', riderId: 'HG-RD-3340', rider: 'Karim Hossain', route: 'Kacchi Bhai → Dhanmondi', km: 4.2, earning: 30, payment: 'cash', surge: 1.0, status: 'completed', cod: 890, date: '2026-07-30' },
    { id: 'HG-98212', type: 'parcel', riderId: 'HG-RD-4521', rider: 'Rakibul Islam', route: 'Banani → Uttara', km: 14, earning: 180, payment: 'digital', surge: 1.5, status: 'in_progress', cod: 0, date: '2026-07-31' },
    { id: 'HG-98213', type: 'ride', riderId: 'HG-RD-3341', rider: 'Sultana Begum', route: 'Uttara → Airport', km: 8.1, earning: 320, payment: 'digital', surge: 1.8, status: 'accepted', cod: 0, date: '2026-07-31' },
    { id: 'HG-98214', type: 'food', riderId: 'HG-RD-9921', rider: 'Tanvir Ahmed', route: 'Pizza Hut → Banani', km: 3.1, earning: 30, payment: 'cash', surge: 1.0, status: 'completed', cod: 1250, date: '2026-07-29' },
    { id: 'HG-98215', type: 'ride', riderId: 'HG-RD-1102', rider: 'Sumon Miah', route: 'GEC → Agrabad', km: 6.5, earning: 220, payment: 'digital', surge: 1.0, status: 'cancelled', cod: 0, date: '2026-07-28' },
  ];

  const riderPayouts = [
    { id: 'HG-PY-8821', riderId: 'HG-RD-9921', rider: 'Tanvir Ahmed', amount: 12450, method: 'bKash', periodFrom: '2026-07-20', periodTo: '2026-07-26', ref: 'BK-778812', paidAt: '2026-07-27T14:20:00', status: 'paid' },
    { id: 'HG-PY-8820', riderId: 'HG-RD-4521', rider: 'Rakibul Islam', amount: 8900, method: 'Nagad', periodFrom: '2026-07-20', periodTo: '2026-07-26', ref: 'NG-441120', paidAt: '2026-07-27T15:05:00', status: 'paid' },
    { id: 'HG-PY-8819', riderId: 'HG-RD-3341', rider: 'Sultana Begum', amount: 15200, method: 'Bank', periodFrom: '2026-07-13', periodTo: '2026-07-19', ref: 'BNK-99201', paidAt: '2026-07-20T11:00:00', status: 'paid' },
    { id: 'HG-PY-8818', riderId: 'HG-RD-8834', rider: 'Farzana Akter', amount: 6700, method: 'bKash', periodFrom: '2026-07-20', periodTo: '2026-07-26', ref: '', paidAt: null, status: 'pending' },
  ];

  const merchants = [
    { id: 'HG-MRT-92103', name: 'Fresh Mart Express', owner: 'Tanvir Ahmed', category: 'Grocery & Market', district: 'Dhaka', isOpen: true, acceptingOrders: true, status: 'active', rating: 4.6, gmvToday: 42800 },
    { id: 'HG-MRT-11024', name: 'Lazz Pharma', owner: 'Farhan Khan', category: 'Health & Beauty', district: 'Dhaka', isOpen: true, acceptingOrders: true, status: 'active', rating: 4.8, gmvToday: 18500 },
    { id: 'HG-MRT-44921', name: 'Bengal Pure Foods', owner: 'Sadia Afrin', category: 'Restaurant & Cafe', district: 'Chattogram', isOpen: true, acceptingOrders: false, status: 'active', rating: 4.4, gmvToday: 9200 },
    { id: 'HG-MRT-55210', name: 'Apex Footwear Outlet', owner: 'Jahid Hasan', category: 'Fashion & Apparel', district: 'Sylhet', isOpen: false, acceptingOrders: false, status: 'pending', rating: 0, gmvToday: 0 },
    { id: 'HG-MRT-66110', name: 'Meena Green', owner: 'Nasrin Sultana', category: 'Grocery & Market', district: 'Khulna', isOpen: true, acceptingOrders: true, status: 'active', rating: 4.5, gmvToday: 15600 },
    { id: 'HG-MRT-77120', name: 'Gourmet Mania', owner: 'Mahbubur Rahman', category: 'Restaurant & Cafe', district: 'Dhaka', isOpen: false, acceptingOrders: false, status: 'onboarding', rating: 0, gmvToday: 0 },
  ];

  const merchantOnboarding = [
    { id: 'ONB-01', merchantId: 'HG-MRT-77120', businessName: 'Gourmet Mania', owner: 'Mahbubur Rahman', category: 'Restaurant & Cafe', phone: '+880 1712-345678', email: 'gourmet@mail.com', address: 'Road 11, Banani', city: 'Dhaka', district: 'Dhaka', zip: '1213', docs: ['Trade License', 'NID'], status: 'pending', submitted: '2026-07-29' },
    { id: 'ONB-02', merchantId: 'HG-MRT-55210', businessName: 'Apex Footwear Outlet', owner: 'Jahid Hasan', category: 'Fashion & Apparel', phone: '+880 1813-456789', email: 'apex@mail.com', address: 'Zindabazar', city: 'Sylhet', district: 'Sylhet', zip: '3100', docs: ['Trade License', 'NID', 'Storefront Photo'], status: 'pending', submitted: '2026-07-28' },
    { id: 'ONB-03', merchantId: 'HG-MRT-88901', businessName: 'Tech Corner BD', owner: 'Imran Kabir', category: 'Electronics', phone: '+880 1914-567890', email: 'techcorner@mail.com', address: 'Agrabad', city: 'Chattogram', district: 'Chattogram', zip: '4100', docs: ['Trade License'], status: 'changes_requested', submitted: '2026-07-22' },
  ];

  const merchantOrders = [
    { id: 'HG-88219', store: 'Fresh Mart Express', customer: 'Ariful Salman', priority: 'standard', status: 'delivered', total: 1250, date: '2026-07-30' },
    { id: 'HG-88218', store: 'Lazz Pharma', customer: 'Nadia Tabassum', priority: 'express', status: 'ready', total: 680, date: '2026-07-31' },
    { id: 'HG-88217', store: 'Bengal Pure Foods', customer: 'Nasreen Jahan', priority: 'priority', status: 'preparing', total: 920, date: '2026-07-31' },
    { id: 'HG-88216', store: 'Meena Green', customer: 'Farzana Zaman', priority: 'scheduled', status: 'new_order', total: 1540, date: '2026-07-31' },
    { id: 'HG-88215', store: 'Chillox Cafe', customer: 'Sumaiya Akhter', priority: 'standard', status: 'rejected', total: 410, date: '2026-07-29' },
    { id: 'HG-88214', store: 'Fresh Mart Express', customer: 'Mahir Ahmed', priority: 'standard', status: 'delivered', total: 780, date: '2026-07-28' },
  ];

  const merchantPayouts = [
    { id: 'PAY-99201-BD', storeId: 'HG-MRT-92103', store: 'Fresh Mart Express', amount: 32400, method: 'Bank', status: 'pending', earlyRequest: true, date: '2026-07-30' },
    { id: 'PAY-99188-BD', storeId: 'HG-MRT-11024', store: 'Lazz Pharma', amount: 18750, method: 'bKash', status: 'processing', earlyRequest: false, date: '2026-07-29' },
    { id: 'PAY-99142-BD', storeId: 'HG-MRT-66110', store: 'Meena Green', amount: 22100, method: 'Nagad', status: 'completed', earlyRequest: false, date: '2026-07-22' },
    { id: 'PAY-99110-BD', storeId: 'HG-MRT-44921', store: 'Bengal Pure Foods', amount: 9800, method: 'Bank', status: 'pending', earlyRequest: false, date: '2026-07-31' },
  ];

  const courierAgents = [
    { id: 'CG-99420', name: 'Shakib Al Hasan', phone: '+880 1711-223344', vehicle: 'Motorcycle', plate: 'DHAKA-HA-12-3456', rating: 4.9, deliveries: 1240, verified: true, district: 'Dhaka', status: 'active', online: true },
    { id: 'CG-88124', name: 'Runa Nahar', phone: '+880 1812-334455', vehicle: 'Van', plate: 'DHAKA-GA-23-4567', rating: 4.7, deliveries: 890, verified: true, district: 'Dhaka', status: 'active', online: true },
    { id: 'CG-77211', name: 'Farhan Ahmed', phone: '+880 1913-445566', vehicle: 'Motorcycle', plate: 'CTG-KA-34-5678', rating: 4.5, deliveries: 610, verified: false, district: 'Chattogram', status: 'active', online: false },
    { id: 'CG-44322', name: 'Imran Azad', phone: '+880 1614-556677', vehicle: 'Bicycle', plate: 'N/A', rating: 4.3, deliveries: 220, verified: true, district: 'Sylhet', status: 'suspended', online: false },
    { id: 'CG-33109', name: 'Fahim Ahmed', phone: '+880 1715-667788', vehicle: 'Motorcycle', plate: 'DHAKA-CHA-45-6789', rating: 4.8, deliveries: 980, verified: true, district: 'Dhaka', status: 'active', online: true },
  ];

  const courierKyc = [
    { id: 'KYC-C-01', agentId: 'CG-77211', agentName: 'Farhan Ahmed', docs: ['Driving License', 'NID', 'Vehicle Registration'], status: 'pending', submitted: '2026-07-28', bankVerified: false },
    { id: 'KYC-C-02', agentId: 'CG-44322', agentName: 'Imran Azad', docs: ['NID'], status: 'pending', submitted: '2026-07-26', bankVerified: false },
    { id: 'KYC-C-03', agentId: 'CG-99420', agentName: 'Shakib Al Hasan', docs: ['Driving License', 'NID', 'Vehicle Registration'], status: 'verified', submitted: '2026-05-01', bankVerified: true },
    { id: 'KYC-C-04', agentId: 'CG-88124', agentName: 'Runa Nahar', docs: ['Driving License', 'NID', 'Vehicle Registration'], status: 'verified', submitted: '2026-04-12', bankVerified: true },
  ];

  const courierParcels = [
    { id: 'HG-98421', priority: 'express', agentId: 'CG-99420', agent: 'Shakib Al Hasan', pickup: 'Gulshan Peak', drop: 'Motijheel Hub', weightKg: 1.2, distanceKm: 11, earnings: 180, surge: 20, status: 'in_transit', date: '2026-07-31' },
    { id: 'HG-98420', priority: 'standard', agentId: 'CG-88124', agent: 'Runa Nahar', pickup: 'Dhanmondi Hub', drop: 'Mirpur DOHS', weightKg: 3.0, distanceKm: 8, earnings: 150, surge: 0, status: 'picked_up', date: '2026-07-31' },
    { id: 'HG-98419', priority: 'priority', agentId: 'CG-33109', agent: 'Fahim Ahmed', pickup: 'Uttara', drop: 'Airport Cargo', weightKg: 5.5, distanceKm: 6, earnings: 215, surge: 35, status: 'assigned', date: '2026-07-31' },
    { id: 'HG-98418', priority: 'standard', agentId: 'CG-99420', agent: 'Shakib Al Hasan', pickup: 'Banani', drop: 'Bashundhara', weightKg: 0.8, distanceKm: 5, earnings: 95, surge: 0, status: 'delivered', date: '2026-07-30' },
    { id: 'HG-98417', priority: 'express', agentId: 'CG-77211', agent: 'Farhan Ahmed', pickup: 'Agrabad', drop: 'GEC', weightKg: 2.1, distanceKm: 4, earnings: 110, surge: 15, status: 'failed', date: '2026-07-29' },
  ];

  const courierWithdrawals = [
    { id: 'WD-01', agentId: 'CG-99420', agent: 'Shakib Al Hasan', amount: 12500, method: 'bKash', bankLast4: '7788', status: 'pending', date: '2026-07-31' },
    { id: 'WD-02', agentId: 'CG-88124', agent: 'Runa Nahar', amount: 4800, method: 'Bank', bankLast4: '2211', status: 'pending', date: '2026-07-30' },
    { id: 'WD-03', agentId: 'CG-33109', agent: 'Fahim Ahmed', amount: 9200, method: 'Nagad', bankLast4: '3344', status: 'approved', date: '2026-07-28' },
    { id: 'WD-04', agentId: 'CG-77211', agent: 'Farhan Ahmed', amount: 3100, method: 'bKash', bankLast4: '5566', status: 'rejected', date: '2026-07-27' },
  ];

  const incentives = [
    { id: 'INC-01', title: 'Eid Bonus Mega Sprint', description: 'Complete 20 deliveries this weekend for bonus', multiplier: 1.5, district: 'Dhaka', goalDeliveries: 20, bonusTk: 5000, validUntil: '2026-08-15', active: true, status: 'active' },
    { id: 'INC-02', title: 'Winter Night Special', description: '1.5x after 10 PM', multiplier: 1.5, district: 'Chattogram', goalDeliveries: 8, bonusTk: 1500, validUntil: '2026-12-31', active: true, status: 'active' },
    { id: 'INC-03', title: 'Downtown Zone Challenge', description: '8 deliveries in downtown', multiplier: 1.0, district: 'Dhaka', goalDeliveries: 8, bonusTk: 2500, validUntil: '2026-08-01', active: false, status: 'scheduled' },
  ];

  const pricing = {
    customer: {
      rideBase: 30, ridePerKm: 15, ridePerMin: 1, rideMinimum: 50,
      foodDeliveryFee: 30, freeDeliveryThreshold: 300,
      parcelBase: 40, parcelPerKm: 12, parcelPerKg: 8, parcelMinimum: 50,
      marketplaceDelivery: 40, hotelServiceFeePct: 5, rentalDriverPerDay: 1500, rentalInsurancePerDay: 300,
    },
    rider: {
      rideBase: 30, ridePerKm: 15, ridePerMin: 1, rideMinimum: 50,
      bikeMultiplier: 0.7, carMultiplier: 1.0, xlMultiplier: 1.5,
      foodJobFee: 30, parcelBase: 40, parcelPerKm: 12, parcelPerKg: 8, parcelMinimum: 50,
      defaultSurge: 1.8, platformCommissionPct: 15,
    },
    merchant: {
      platformCommissionPct: 15, orderServiceFee: 25, taxVatPct: 5,
      settlementCycle: 'weekly', earlyPayoutFeePct: 2, minPayoutAmount: 1000,
    },
    courier: {
      parcelBase: 50, perKm: 12, perKg: 8, expressMultiplier: 1.4, priorityMultiplier: 1.25,
      surgeCap: 100, platformCommissionPct: 12, weeklyGoalDeliveries: 50, topPerformerMultiplier: 1.2, withdrawalMin: 500,
    },
  };

  const pricingAudit = [
    { id: 'AUD-01', panel: 'rider', field: 'rideBase', oldValue: 25, newValue: 30, by: 'Admin User', at: '2026-07-20T10:00:00' },
  ];

  const settings = {
    orgName: 'HillGo Enterprise',
    orgEmail: 'admin@hillgo.app',
    timezone: 'Asia/Dhaka',
    twoFactor: true,
    emailAlerts: true,
    smsAlerts: false,
  };

  const activityLog = [
    { id: 'LOG-01', text: 'Gazipur marked Closed — emergency maintenance', by: 'Admin Kabir', at: '2026-07-30T18:40:00' },
    { id: 'LOG-02', text: 'Rider KYC approved: Rakibul Islam', by: 'Admin User', at: '2026-07-30T12:10:00' },
    { id: 'LOG-03', text: 'Merchant payout completed: Meena Green ৳22,100', by: 'Admin User', at: '2026-07-22T16:00:00' },
  ];

  return {
    divisions,
    regionDistricts,
    customers,
    rides,
    foodOrders,
    customerParcels,
    riders,
    riderKyc,
    trips,
    riderPayouts,
    merchants,
    merchantOnboarding,
    merchantOrders,
    merchantPayouts,
    courierAgents,
    courierKyc,
    courierParcels,
    courierWithdrawals,
    incentives,
    pricing,
    pricingAudit,
    settings,
    activityLog,
  };
})();
