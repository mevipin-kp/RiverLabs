<script setup>
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { ArrowLeft, ArrowRight, ArrowUpRight, Check, ChevronDown, Search, Sparkles } from '@lucide/vue'

const props = defineProps({ product: { type: Object, required: true } })

const products = {
  'river-auto': {
    shortName: 'River Auto', category: 'AUTOMOTIVE OPERATIONS',
    title: 'See every vehicle. Keep the business moving.',
    description: 'Bring stock, sales, and workshop activity into one clear operational view.',
    apps: ['Overview', 'Vehicles', 'Sales', 'Workshop'], activeApps: ['Overview', 'Vehicles', 'Workshop'],
    outcome: 'From the first vehicle record to the final handover, keep the next action in view.',
    screens: [
      { eyebrow: '01 / VEHICLE OVERVIEW', statement: 'Know what is ready to move.', appTitle: 'Vehicle overview', view: 'overview', period: 'This month', chartAxis: ['01 MAY', '08 MAY', '15 MAY', '22 MAY'], metrics: [{ label: 'In stock', value: '128', note: 'Across 3 locations' }, { label: 'Reserved', value: '24', note: 'Awaiting handover' }, { label: 'In preparation', value: '17', note: '6 due this week' }, { label: 'Workshop queue', value: '09', note: '3 awaiting parts' }], chartTitle: 'Vehicle movement', bars: [44, 61, 52, 74, 67, 91, 70, 84, 60, 76, 53, 95], sideTitle: 'Needs attention', sideRows: [['Prep overdue', '4 vehicles', 'amber'], ['Documents pending', '7 vehicles', 'blue'], ['Service due', '3 vehicles', 'amber']], columns: ['Vehicle', 'Location', 'Status', 'Updated'], rows: [['Toyota Land Cruiser', 'Dubai South', 'Ready', '12 min ago'], ['Nissan Patrol', 'Abu Dhabi', 'In preparation', '28 min ago'], ['BMW X5', 'Dubai South', 'Reserved', '1 hr ago']] },
      { eyebrow: '02 / SALES HANDOVER', statement: 'Follow each vehicle from intake to handover.', appTitle: 'Vehicle pipeline', view: 'pipeline', lanes: [{ title: 'Intake', count: '08', cards: [['Range Rover Sport', 'RA-2048 · Dubai', 'Documents'], ['Lexus RX 350', 'RA-2051 · Abu Dhabi', 'Inspection']] }, { title: 'Preparation', count: '12', cards: [['Toyota Prado', 'RA-2036 · Dubai', 'Workshop'], ['BMW X5', 'RA-2041 · Sharjah', 'Detailing']] }, { title: 'Ready', count: '06', cards: [['Nissan Patrol', 'RA-2018 · Dubai', 'Ready'], ['Audi Q7', 'RA-2022 · Abu Dhabi', 'Ready']] }, { title: 'Reserved', count: '04', cards: [['Mercedes GLE', 'RA-2012 · Dubai', 'Handover']] }] },
      { eyebrow: '03 / WORKSHOP QUEUE', statement: 'Keep service work visible before it delays delivery.', appTitle: 'Workshop activity', view: 'table', period: 'All locations', metrics: [{ label: 'Open jobs', value: '09', note: '3 high priority' }, { label: 'Parts pending', value: '03', note: '2 expected today' }, { label: 'Ready for check', value: '04', note: 'Next: 10:30' }], columns: ['Job', 'Vehicle', 'Assigned to', 'Due', 'Status'], rows: [['WO-1048 · 80k service', 'Toyota Land Cruiser', 'M. Rahman', 'Today, 10:30', 'In progress'], ['WO-1052 · Brake check', 'Nissan Patrol', 'A. Khan', 'Today, 12:00', 'Parts pending'], ['WO-1055 · Delivery prep', 'BMW X5', 'S. Joseph', 'Today, 14:00', 'Inspection']], noteTitle: 'Next handover', noteValue: 'Toyota Land Cruiser', noteMeta: 'Today · 16:00 · Dubai South' },
    ],
  },
  'river-hire': {
    shortName: 'River Hire', category: 'RECRUITMENT & HR',
    title: 'Move the right candidates forward.',
    description: 'Keep roles, candidate stages, interviews, and placements connected in one workspace.',
    apps: ['Overview', 'Roles', 'Candidates', 'Placements'], activeApps: ['Candidates', 'Candidates', 'Placements'],
    outcome: 'Give every role a clear next step, from first shortlist through placement.',
    screens: [
      { eyebrow: '01 / CANDIDATE PIPELINE', statement: 'See where every role stands.', appTitle: 'Recruitment pipeline', view: 'pipeline', lanes: [{ title: 'New', count: '18', cards: [['Aisha K.', 'Finance Manager · RL-204', 'New today'], ['Daniel M.', 'Product Designer · RL-198', 'Referred']] }, { title: 'Screening', count: '11', cards: [['Omar H.', 'Operations Lead · RL-201', 'Screen call'], ['Fatima R.', 'Finance Manager · RL-204', 'Review CV']] }, { title: 'Interview', count: '07', cards: [['Maya T.', 'Product Designer · RL-198', 'Round 2'], ['Khalid S.', 'Sales Director · RL-190', 'Tomorrow']] }, { title: 'Offer', count: '03', cards: [['Rohan P.', 'Operations Lead · RL-201', 'Offer sent']] }] },
      { eyebrow: '02 / CANDIDATE REVIEW', statement: 'Keep the conversation and next action together.', appTitle: 'Candidate profile', view: 'detail', recordId: 'CAND-0842 · ROLE RL-204', recordTitle: 'Aisha Khan', recordStatus: 'Screening', recordMeta: 'Finance Manager · Dubai', facts: [['Experience', '8 years'], ['Current location', 'Dubai, UAE'], ['Notice period', '30 days'], ['Source', 'Referral']], timeline: [['Today, 09:42', 'Profile added to Finance Manager role'], ['Yesterday, 15:10', 'CV reviewed by R. Thomas'], ['14 May, 11:30', 'Initial call scheduled']], noteTitle: 'Next step', noteValue: 'Screening call', noteMeta: 'Assigned to R. Thomas · Today, 14:00' },
      { eyebrow: '03 / PLACEMENT VISIBILITY', statement: 'Understand progress across active roles.', appTitle: 'Role activity', view: 'overview', period: 'This month', chartAxis: ['01 MAY', '08 MAY', '15 MAY', '22 MAY'], metrics: [{ label: 'Open roles', value: '26', note: 'Across 9 clients' }, { label: 'Interviews', value: '34', note: 'Scheduled this week' }, { label: 'Offers', value: '08', note: 'Awaiting response' }, { label: 'Placements', value: '12', note: 'This quarter' }], chartTitle: 'Candidate progression', bars: [32, 42, 56, 47, 68, 63, 77, 71, 89, 82, 91, 100], sideTitle: 'Active roles', sideRows: [['Finance Manager', '6 candidates', 'blue'], ['Operations Lead', '4 candidates', 'amber'], ['Product Designer', '8 candidates', 'blue']], columns: ['Role', 'Client', 'Stage', 'Next activity'], rows: [['Finance Manager', 'Northstar Group', 'Interview', '2 today'], ['Operations Lead', 'Cedar Works', 'Offer', 'Response due'], ['Product Designer', 'Fieldnote', 'Screening', '3 reviews']] },
    ],
  },
  'river-build': {
    shortName: 'River Build', category: 'BUILDING & FACILITIES',
    title: 'Keep every property in good working order.',
    description: 'Coordinate buildings, planned maintenance, and open service requests from one view.',
    apps: ['Portfolio', 'Properties', 'Work orders', 'Inspections'], activeApps: ['Portfolio', 'Work orders', 'Properties'],
    outcome: 'See the condition of the portfolio and the work that needs attention next.',
    screens: [
      { eyebrow: '01 / PROPERTY PORTFOLIO', statement: 'See the health of every building.', appTitle: 'Portfolio overview', view: 'overview', period: 'This month', chartAxis: ['01 MAY', '08 MAY', '15 MAY', '22 MAY'], metrics: [{ label: 'Properties', value: '18', note: 'Across 4 districts' }, { label: 'Open requests', value: '42', note: '9 high priority' }, { label: 'Planned visits', value: '16', note: 'Next 7 days' }, { label: 'Awaiting review', value: '07', note: 'Work completed' }], chartTitle: 'Requests by week', bars: [63, 54, 72, 67, 82, 59, 77, 68, 92, 73, 85, 62], sideTitle: 'Property watchlist', sideRows: [['Marina Tower', '6 open requests', 'amber'], ['Cedar Court', '2 planned visits', 'blue'], ['West Bay Offices', '1 overdue item', 'red']], columns: ['Property', 'Open work', 'Next visit', 'Status'], rows: [['Marina Tower', '06 requests', 'Today, 13:00', 'Attention'], ['Cedar Court', '02 requests', 'Tomorrow', 'Scheduled'], ['West Bay Offices', '01 request', '16 May', 'Overdue']] },
      { eyebrow: '02 / MAINTENANCE WORK', statement: 'Route service requests to the right team.', appTitle: 'Work order board', view: 'pipeline', lanes: [{ title: 'New', count: '12', cards: [['AC not cooling', 'Marina Tower · Unit 804', 'Priority high'], ['Light replacement', 'Cedar Court · Lobby', 'Routine']] }, { title: 'Assigned', count: '09', cards: [['Water leak check', 'West Bay · Level 2', 'Vendor confirmed'], ['Door closer repair', 'Marina Tower · L1', 'Today, 14:00']] }, { title: 'In progress', count: '14', cards: [['Lift inspection', 'Cedar Court · Lift B', 'On site'], ['Filter replacement', 'Marina Tower · Roof', 'In progress']] }, { title: 'Review', count: '07', cards: [['Pump service', 'West Bay · Plant room', 'Completion check']] }] },
      { eyebrow: '03 / PROPERTY DETAIL', statement: 'Keep inspections, assets, and open work connected.', appTitle: 'Marina Tower', view: 'detail', recordId: 'PROPERTY · DUBAI MARINA', recordTitle: 'Marina Tower', recordStatus: 'Operational', recordMeta: 'Mixed-use · 24 floors · 186 units', facts: [['Open requests', '6 active'], ['Next inspection', '18 May · Fire systems'], ['Planned maintenance', '4 tasks this month'], ['Property lead', 'N. Fernandes']], timeline: [['Today, 08:50', 'AC service request assigned to facilities team'], ['Yesterday, 16:12', 'Common area inspection completed'], ['12 May, 13:40', 'Lift B maintenance record updated']], noteTitle: 'Next scheduled visit', noteValue: 'Fire systems inspection', noteMeta: '18 May · 09:00 · Marina Tower' },
    ],
  },
  'river-retail': {
    shortName: 'River Retail', category: 'RETAIL & COMMERCE',
    title: 'Know what is selling—and where stock needs attention.',
    description: 'Bring outlet performance, inventory, and order activity into the same daily view.',
    apps: ['Overview', 'Outlets', 'Inventory', 'Orders'], activeApps: ['Overview', 'Inventory', 'Orders'],
    outcome: 'Move from a sales signal to the stock or order that needs a decision.',
    screens: [
      { eyebrow: '01 / RETAIL OVERVIEW', statement: 'Compare trading across every outlet.', appTitle: 'Retail overview', view: 'overview', period: 'Today', chartAxis: ['09 AM', '12 PM', '03 PM', '06 PM'], metrics: [{ label: 'Net sales', value: 'AED 84.2k', note: 'Across 8 outlets' }, { label: 'Orders', value: '1,246', note: 'Today so far' }, { label: 'Low stock', value: '23', note: 'Across 11 items' }, { label: 'Returns', value: '18', note: '1.4% of orders' }], chartTitle: 'Sales through the day', bars: [28, 37, 51, 72, 91, 82, 68, 75, 88, 100, 73, 59], sideTitle: 'Outlet pulse', sideRows: [['Downtown · Dubai', 'AED 18.4k', 'blue'], ['Marina Walk', 'AED 14.1k', 'blue'], ['City Centre · Sharjah', 'Stock alert', 'amber']], columns: ['Outlet', 'Orders', 'Net sales', 'Stock alerts'], rows: [['Downtown · Dubai', '284', 'AED 18,420', '2'], ['Marina Walk', '216', 'AED 14,115', '4'], ['City Centre · Sharjah', '193', 'AED 12,840', '7']] },
      { eyebrow: '02 / INVENTORY CONTROL', statement: 'Catch replenishment needs before shelves run low.', appTitle: 'Replenishment queue', view: 'table', period: 'All outlets', metrics: [{ label: 'Below threshold', value: '23', note: '11 products' }, { label: 'Transfers suggested', value: '08', note: 'Between outlets' }, { label: 'Supplier orders', value: '05', note: 'Ready to review' }], columns: ['Product', 'Outlet', 'On hand', 'Threshold', 'Suggested action'], rows: [['Arabica Blend · 1 kg', 'Downtown · Dubai', '4', '12', 'Transfer 8'], ['Ceramic Cup · Sand', 'Marina Walk', '2', '10', 'Reorder 12'], ['Pour-over Set', 'City Centre · Sharjah', '3', '8', 'Transfer 5']], noteTitle: 'Suggested transfer', noteValue: '8 units · Downtown → Marina', noteMeta: 'Based on current outlet stock levels' },
      { eyebrow: '03 / ORDER FLOW', statement: 'Keep every order moving to the right next step.', appTitle: 'Order fulfilment', view: 'pipeline', lanes: [{ title: 'Received', count: '28', cards: [['ORD-82418', 'Downtown · Pickup', 'New'], ['ORD-82423', 'Online · Delivery', 'New']] }, { title: 'Preparing', count: '16', cards: [['ORD-82402', 'Marina Walk · Pickup', 'Picking'], ['ORD-82409', 'Online · Delivery', 'Picking']] }, { title: 'Ready', count: '11', cards: [['ORD-82394', 'Downtown · Pickup', 'Ready 10:42'], ['ORD-82399', 'Online · Delivery', 'Ready']] }, { title: 'Completed', count: '73', cards: [['ORD-82376', 'City Centre · Pickup', 'Collected']] }] },
    ],
  },
  'river-fleet': {
    shortName: 'River Fleet', category: 'FLEET OPERATIONS',
    title: 'Keep vehicles available and work on schedule.',
    description: 'See fleet status, assignments, and upcoming maintenance without stitching together spreadsheets.',
    apps: ['Overview', 'Vehicles', 'Assignments', 'Maintenance'], activeApps: ['Overview', 'Assignments', 'Maintenance'],
    outcome: 'Make vehicle availability and the next maintenance action clear to the whole team.',
    screens: [
      { eyebrow: '01 / FLEET OVERVIEW', statement: 'See what is available, assigned, or due.', appTitle: 'Fleet overview', view: 'overview', period: 'Today', chartAxis: ['06 AM', '10 AM', '02 PM', '06 PM'], metrics: [{ label: 'Total vehicles', value: '214', note: 'Across 5 depots' }, { label: 'Available', value: '38', note: 'Ready to assign' }, { label: 'On assignment', value: '149', note: 'Active today' }, { label: 'Maintenance due', value: '12', note: 'Next 14 days' }], chartTitle: 'Vehicle availability', bars: [74, 81, 66, 88, 72, 91, 77, 68, 85, 71, 95, 80], sideTitle: 'Depot status', sideRows: [['Al Quoz', '8 available', 'blue'], ['Mussafah', '6 maintenance due', 'amber'], ['Ras Al Khor', '3 unassigned', 'blue']], columns: ['Vehicle', 'Depot', 'Assignment', 'Next service'], rows: [['Toyota Hiace · F-1082', 'Al Quoz', 'Route 04 · Active', '21 May'], ['Nissan Urvan · F-1140', 'Mussafah', 'Unassigned', '18 May'], ['Ford Transit · F-1091', 'Ras Al Khor', 'Route 11 · Active', '24 May']] },
      { eyebrow: '02 / DAILY ASSIGNMENTS', statement: 'Match vehicles and drivers to today’s work.', appTitle: 'Assignment board', view: 'pipeline', lanes: [{ title: 'Unassigned', count: '08', cards: [['F-1140 · Nissan Urvan', 'Mussafah · 14 seats', 'Available'], ['F-1208 · Toyota Hiace', 'Al Quoz · 12 seats', 'Available']] }, { title: 'Scheduled', count: '16', cards: [['F-1082 · Toyota Hiace', 'Route 04 · M. Ali', '08:30 start'], ['F-1099 · Ford Transit', 'Route 08 · J. Peter', '09:00 start']] }, { title: 'In progress', count: '149', cards: [['F-1024 · Isuzu NPR', 'Route 17 · A. Karim', 'In progress'], ['F-1161 · Nissan Urvan', 'Route 03 · S. Thomas', 'In progress']] }, { title: 'Returning', count: '04', cards: [['F-1033 · Toyota Hiace', 'Route 02 · Al Quoz', 'ETA 16:20']] }] },
      { eyebrow: '03 / PREVENTIVE MAINTENANCE', statement: 'Plan service around vehicle availability.', appTitle: 'Maintenance schedule', view: 'table', period: 'Next 30 days', metrics: [{ label: 'Due soon', value: '12', note: 'Next 14 days' }, { label: 'Booked', value: '08', note: 'Workshop confirmed' }, { label: 'Overdue', value: '02', note: 'Review needed' }], columns: ['Vehicle', 'Service', 'Depot', 'Due', 'Availability'], rows: [['F-1140 · Nissan Urvan', 'Oil & filter', 'Mussafah', '18 May', 'Unassigned'], ['F-1082 · Toyota Hiace', '80,000 km', 'Al Quoz', '21 May', 'Assigned 08:30'], ['F-1066 · Ford Transit', 'Brake inspection', 'Ras Al Khor', 'Overdue', 'Needs review']], noteTitle: 'Suggested booking', noteValue: 'F-1140 · Nissan Urvan', noteMeta: 'Mussafah workshop · 18 May, 10:00' },
    ],
  },
  'river-flow': {
    shortName: 'River Flow', category: 'WORKFLOW & PROCESS AUTOMATION',
    title: 'Make repeatable work visible and dependable.',
    description: 'Route requests, track each run, and give your team a clear path through exceptions.',
    apps: ['Overview', 'Workflows', 'Runs', 'Exceptions'], activeApps: ['Overview', 'Workflows', 'Exceptions'],
    outcome: 'Give people a clear view of what runs automatically, what needs review, and what happens next.',
    screens: [
      { eyebrow: '01 / WORKFLOW OVERVIEW', statement: 'See what is running—and what needs a hand.', appTitle: 'Automation overview', view: 'overview', period: 'This week', chartAxis: ['MON', 'TUE', 'WED', 'THU'], metrics: [{ label: 'Active workflows', value: '24', note: 'Across 6 teams' }, { label: 'Runs completed', value: '8,492', note: 'This week' }, { label: 'Needs review', value: '07', note: 'Across 3 workflows' }, { label: 'Time returned', value: '316 hrs', note: 'Estimated this month' }], chartTitle: 'Workflow activity', bars: [38, 55, 47, 68, 59, 82, 73, 90, 64, 79, 95, 86], sideTitle: 'Needs attention', sideRows: [['Invoice approval', '2 items', 'amber'], ['New starter setup', '1 item', 'red'], ['Order validation', '4 items', 'amber']], columns: ['Workflow', 'Runs', 'Completion', 'Latest activity'], rows: [['Invoice processing', '1,284', '98.4%', '2 min ago'], ['Order validation', '946', '99.1%', '8 min ago'], ['New starter setup', '38', 'Review needed', '12 min ago']] },
      { eyebrow: '02 / WORKFLOW DESIGN', statement: 'Make the path from request to outcome explicit.', appTitle: 'Invoice approval · v3', view: 'workflow', nodes: [['TRIGGER', 'Invoice received', 'New finance request'], ['ACTION', 'Read invoice fields', 'Vendor · amount · due date'], ['CONDITION', 'Route by amount', 'Under AED 5,000 → team lead'], ['APPROVAL', 'Manager review', 'Assigned to budget owner'], ['OUTCOME', 'Record & notify', 'Update finance ledger']], branch: 'Over AED 5,000 → finance director approval', noteTitle: 'Workflow status', noteValue: 'Active · Version 3', noteMeta: 'Last edited by A. Rahman · 15 May' },
      { eyebrow: '03 / EXCEPTION REVIEW', statement: 'Give exceptions a clear owner and next step.', appTitle: 'Run details', view: 'detail', recordId: 'RUN-248193 · INVOICE PROCESSING', recordTitle: 'Needs a quick review', recordStatus: 'Action required', recordMeta: 'Al Noor Supplies · INV-20481 · AED 8,450', facts: [['Started', 'Today · 10:42'], ['Stopped at', 'Manager approval'], ['Assigned to', 'Finance team'], ['Source', 'AP inbox']], timeline: [['10:42', 'Invoice received and fields captured'], ['10:42', 'Vendor matched to supplier record'], ['10:43', 'Routed to finance director by amount rule']], noteTitle: 'Next step', noteValue: 'Review invoice and approve or return', noteMeta: 'Workflow resumes when a decision is recorded' },
    ],
  },
}

const page = products[props.product.href.split('/').pop()] ?? products['river-flow']
const contactHref = `/contact?product=${encodeURIComponent(props.product.name)}`
const activeScreen = ref(0)
const pauseRotation = ref(false)
const pointerInside = ref(false)
const focusInside = ref(false)
const pointer = reactive({ x: 0, y: 0 })
let rotationTimer

const insights = {
  'river-auto': [
    { category: 'WORKSHOP · REPEATED DELAY', title: 'Parts waits are holding up vehicle handovers', detail: '4 open repair jobs have been waiting on parts for more than two days.', action: 'Review the workshop queue', impact: '18 hrs', label: 'across 4 jobs', screen: 2, tone: 'amber' },
    { category: 'STOCK · POSSIBLE ACTION', title: 'Similar vehicles are moving at different rates', detail: 'Compare days in stock by location before arranging a transfer.', action: 'Compare vehicle movement', impact: '3 units', label: 'to review', screen: 0, tone: 'blue' },
  ],
  'river-hire': [
    { category: 'CANDIDATES · PIPELINE PATTERN', title: 'Screening waits are building on two roles', detail: 'Several candidates have been in screening for more than five working days.', action: 'Review candidate stages', impact: '7 people', label: 'awaiting review', screen: 0, tone: 'amber' },
    { category: 'INTERVIEWS · FOLLOW-UP', title: 'Feedback is missing after recent interviews', detail: 'A few active candidates have no recorded interviewer feedback yet.', action: 'Open candidate activity', impact: '3 notes', label: 'not recorded', screen: 1, tone: 'blue' },
  ],
  'river-build': [
    { category: 'PROPERTY · REPEATED REQUEST', title: 'Similar AC issues are recurring at Marina Tower', detail: 'Recent requests point to repeat cooling issues across the same property.', action: 'Review property work', impact: '6 requests', label: 'open now', screen: 2, tone: 'amber' },
    { category: 'MAINTENANCE · UPCOMING', title: 'Planned visits may overlap at one site', detail: 'Check the schedule before confirming the next contractor visit.', action: 'Review the work board', impact: '2 visits', label: 'this week', screen: 1, tone: 'blue' },
  ],
  'river-retail': [
    { category: 'INVENTORY · STOCK SIGNAL', title: 'Fast-moving items are nearing their outlet threshold', detail: 'Compare current stock with recent order activity before replenishing.', action: 'Review replenishment queue', impact: '23 items', label: 'below threshold', screen: 1, tone: 'amber' },
    { category: 'OUTLETS · PERFORMANCE', title: 'Trading patterns differ between nearby outlets', detail: 'Review sales and available stock before shifting inventory.', action: 'Compare outlet activity', impact: '8 outlets', label: 'in view', screen: 0, tone: 'blue' },
  ],
  'river-fleet': [
    { category: 'MAINTENANCE · AVAILABILITY', title: 'Upcoming service may affect assigned vehicles', detail: 'Check assignments before confirming the next maintenance bookings.', action: 'Review maintenance schedule', impact: '12 vehicles', label: 'due soon', screen: 2, tone: 'amber' },
    { category: 'ASSIGNMENTS · UTILISATION', title: 'Available vehicles and active routes vary by depot', detail: 'Compare depot availability before moving vehicles between teams.', action: 'Review daily assignments', impact: '5 depots', label: 'in view', screen: 1, tone: 'blue' },
  ],
}
const productKey = props.product.href.split('/').pop()
const productInsights = insights[productKey] ?? []
const screens = computed(() => [...page.screens, { view: 'insights', appTitle: 'AI Insights', eyebrow: '04 / AI INSIGHTS' }, { view: 'reports', appTitle: 'Reports & dashboards', eyebrow: '05 / REPORTS & DASHBOARDS' }])
const currentScreen = computed(() => screens.value[activeScreen.value])
const screen = currentScreen
const navigationTargets = {
  'river-auto': { Overview: 0, Vehicles: 0, Sales: 1, Workshop: 2 },
  'river-hire': { Overview: 2, Roles: 0, Candidates: 1, Placements: 2 },
  'river-build': { Portfolio: 0, Properties: 2, 'Work orders': 1, Inspections: 2 },
  'river-retail': { Overview: 0, Outlets: 0, Inventory: 1, Orders: 2 },
  'river-fleet': { Overview: 0, Vehicles: 0, Assignments: 1, Maintenance: 2 },
}
const navigationItems = computed(() => [
  ...page.apps.map((label) => ({ label, screen: navigationTargets[productKey]?.[label] ?? 0 })),
  { label: 'AI Insights', screen: page.screens.length, badge: String(productInsights.length).padStart(2, '0') },
  { label: 'Reports & dashboards', screen: page.screens.length + 1 },
])
const tiltStyle = computed(() => ({
  '--product-tilt-x': `${pointer.y * -2.2}deg`,
  '--product-tilt-y': `${pointer.x * 3.4}deg`,
  '--product-shift-x': `${pointer.x * 4}px`,
  '--product-shift-y': `${pointer.y * -3}px`,
}))

function setScreen(index) { activeScreen.value = (index + screens.value.length) % screens.value.length }
function onPointerMove(event) {
  const bounds = event.currentTarget.getBoundingClientRect()
  pointer.x = ((event.clientX - bounds.left) / bounds.width - .5) * 2
  pointer.y = ((event.clientY - bounds.top) / bounds.height - .5) * 2
}
function resetPointer() { pointer.x = 0; pointer.y = 0; pointerInside.value = false }
function onFocusOut(event) { if (!event.currentTarget.contains(event.relatedTarget)) focusInside.value = false }
function insightAction(index) { setScreen(productInsights[index].screen) }

onMounted(() => {
  document.title = `${page.shortName} | RiverLabs`
  if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    rotationTimer = window.setInterval(() => {
      if (!pauseRotation.value && !pointerInside.value && !focusInside.value && document.visibilityState === 'visible') setScreen(activeScreen.value + 1)
    }, 10000)
  }
})
onUnmounted(() => window.clearInterval(rotationTimer))

function isStatusColumn(screen, index) {
  return /status|stage|completion|availability/i.test(screen.columns[index] ?? '')
}
function statusTone(screen, row, index) {
  if (!isStatusColumn(screen, index)) return ''
  const value = String(row[index]).toLowerCase()
  if (/overdue|attention|pending|awaiting|review|action|required|issue/.test(value)) return 'showcase-cell-attention'
  if (/ready|complete|available|active|operational|placed|approved/.test(value)) return 'showcase-cell-good'
  return 'showcase-cell-neutral'
}
</script>

<template>
  <div class="product-showcase" :class="`showcase-${page.shortName.toLowerCase().replace(' ', '-')}`">
    <header class="showcase-header">
      <a class="showcase-brand" href="/" aria-label="RiverLabs home"><span class="showcase-mark"><i></i><i></i><i></i><i></i><i></i></span><span>RiverLabs</span></a>
      <div class="showcase-header-links"><a class="showcase-back-link" href="/">All products <ArrowLeft :size="15" /></a><a class="showcase-header-cta" :href="contactHref">Talk to our team <ArrowUpRight :size="15" /></a></div>
    </header>

    <main class="showcase-main-layout">
      <section class="showcase-story" aria-label="Product overview">
        <div class="showcase-eyebrow"><span></span>{{ page.category }}</div>
        <h1>{{ page.title }}</h1>
        <p>{{ page.description }}</p>
        <div class="showcase-story-outcome"><span>BUILT AROUND YOUR OPERATIONS</span><strong>{{ page.outcome }}</strong></div>
        <div class="showcase-story-modules"><span>INSIDE {{ page.shortName.toUpperCase() }}</span><ul><li v-for="area in page.apps.slice(0, 3)" :key="area">{{ area }}</li></ul></div>
        <a class="showcase-primary-cta" :href="contactHref">Discuss {{ page.shortName }} <ArrowUpRight :size="16" /></a>
        <div class="showcase-story-foot"><span>{{ page.shortName.toUpperCase() }}</span><i></i><span>PRODUCT PREVIEW</span></div>
      </section>

      <section class="showcase-product-slider" :aria-label="`${page.shortName} product preview slideshow`" @pointerenter="pointerInside = true" @pointerleave="resetPointer" @focusin="focusInside = true" @focusout="onFocusOut">
        <div class="showcase-slider-intro"><div><span>INSIDE {{ page.shortName.toUpperCase() }}</span><h2>{{ screen.eyebrow }}</h2></div><div class="showcase-slide-count"><strong>0{{ activeScreen + 1 }}</strong><i></i><span>0{{ screens.length }}</span></div></div>
        <div class="showcase-product-stage" :class="{ 'showcase-pointer-active': pointerInside }" @pointermove="onPointerMove">
          <Transition name="product-screen" mode="out-in" appear>
          <div :key="activeScreen" class="showcase-screen is-visible" :style="tiltStyle" role="region" :aria-label="`${page.shortName} ${screen.appTitle} interface preview`">
          <div class="showcase-window-bar"><span class="showcase-window-dots"><i></i><i></i><i></i></span><span>{{ page.shortName }} <i>/</i> {{ screen.appTitle }}</span><span class="showcase-sample-label">Sample workspace</span></div>
          <div class="showcase-window-layout">
            <aside class="showcase-sidebar">
              <div class="showcase-app-brand"><span class="showcase-app-mark">{{ page.shortName.split(' ')[1].slice(0, 2).toUpperCase() }}</span><span>{{ page.shortName }}</span></div>
              <div class="showcase-sidebar-label">WORKSPACE</div>
              <button v-for="(app, appIndex) in navigationItems" :key="app.label" class="showcase-sidebar-item" :class="{ active: app.screen === activeScreen }" :aria-current="app.screen === activeScreen ? 'page' : undefined" @click="setScreen(app.screen)"><span class="showcase-sidebar-glyph">{{ ['▦', '◫', '↗', '⌁', '▤', '✳'][appIndex % 6] }}</span><span class="showcase-sidebar-label-text">{{ app.label }}</span><b v-if="app.badge">{{ app.badge }}</b></button>
              <div class="showcase-sidebar-bottom"><span></span> Sample data</div>
            </aside>
            <div class="showcase-app-main">
              <div class="showcase-app-toolbar"><div class="showcase-search"><Search :size="14"/><span>Search {{ page.shortName.split(' ')[1].toLowerCase() }}…</span><kbd>⌘ K</kbd></div><span class="showcase-avatar" aria-hidden="true">RL</span></div>
              <div class="showcase-app-title-row"><div><span class="showcase-app-kicker">{{ page.shortName.toUpperCase() }} / {{ screen.eyebrow.split('/')[1].trim() }}</span><h3>{{ screen.appTitle }}</h3></div><span v-if="screen.period" class="showcase-period" aria-label="Displayed time period">{{ screen.period }} <ChevronDown :size="13" /></span></div>

              <template v-if="screen.view === 'overview'">
                <div class="showcase-metrics" :class="{ 'showcase-metrics-three': screen.metrics.length === 3 }"><div v-for="metric in screen.metrics" :key="metric.label" class="showcase-metric"><span>{{ metric.label }}</span><strong>{{ metric.value }}</strong><small>{{ metric.note }}</small></div></div>
                <div class="showcase-overview-grid">
                  <div class="showcase-chart-panel"><div class="showcase-panel-title"><span>{{ screen.chartTitle }}</span><small>Sample activity</small></div><div class="showcase-chart" role="img" :aria-label="`${screen.chartTitle}, illustrative sample data shown as a bar chart`"><div v-for="(bar, barIndex) in screen.bars" :key="barIndex" class="showcase-bar-wrap"><i :style="{ '--bar-height': `${bar}%`, '--bar-delay': `${barIndex * 45}ms` }"></i></div></div><div class="showcase-chart-axis"><span v-for="label in screen.chartAxis ?? ['WEEK 01', 'WEEK 02', 'WEEK 03', 'WEEK 04']" :key="label">{{ label }}</span></div></div>
                  <div class="showcase-side-panel"><div class="showcase-panel-title"><span>{{ screen.sideTitle }}</span><small>View all <ArrowRight :size="12" /></small></div><div v-for="row in screen.sideRows" :key="row[0]" class="showcase-side-row"><span class="showcase-status-mark" :class="row[2]"></span><span><strong>{{ row[0] }}</strong><small>{{ row[1] }}</small></span><ArrowUpRight :size="13" /></div></div>
                </div>
                <div class="showcase-table-wrap" role="region" tabindex="0" :aria-label="`${screen.appTitle} sample data table`"><div class="showcase-table-title">Recent activity <span>View all <ArrowRight :size="12" /></span></div><table class="showcase-table"><thead><tr><th v-for="column in screen.columns" :key="column">{{ column }}</th></tr></thead><tbody><tr v-for="row in screen.rows" :key="row[0]"><td v-for="(cell, cellIndex) in row" :key="cell" :class="statusTone(screen, row, cellIndex)">{{ cell }}</td></tr></tbody></table></div>
              </template>

              <template v-else-if="screen.view === 'pipeline'">
                <div class="showcase-pipeline-summary"><span>{{ screen.lanes.reduce((sum, lane) => sum + Number(lane.count), 0) }} active records</span><span>Updated just now</span></div>
                <div class="showcase-lanes" role="region" tabindex="0" aria-label="Workflow stages. Scroll horizontally to view all stages"><div v-for="lane in screen.lanes" :key="lane.title" class="showcase-lane"><div class="showcase-lane-title"><span>{{ lane.title }}</span><small>{{ lane.count }}</small></div><article v-for="card in lane.cards" :key="card[0]" class="showcase-work-card"><strong>{{ card[0] }}</strong><small>{{ card[1] }}</small><span class="showcase-card-status"><i></i>{{ card[2] }}</span></article><div class="showcase-add-record" aria-hidden="true">+ Add record</div></div></div>
              </template>

              <template v-else-if="screen.view === 'detail'">
                <div class="showcase-record-header"><div><small>{{ screen.recordId }}</small><h4>{{ screen.recordTitle }}</h4><p>{{ screen.recordMeta }}</p></div><span class="showcase-record-status">{{ screen.recordStatus }}</span></div>
                <div class="showcase-detail-grid"><div class="showcase-detail-panel"><div class="showcase-panel-title"><span>Record details</span><span class="showcase-preview-action">Edit <ArrowUpRight :size="12" /></span></div><div v-for="fact in screen.facts" :key="fact[0]" class="showcase-fact"><span>{{ fact[0] }}</span><strong>{{ fact[1] }}</strong></div></div><div class="showcase-detail-panel"><div class="showcase-panel-title"><span>Activity</span><small>Latest first</small></div><div class="showcase-timeline"><div v-for="event in screen.timeline" :key="event[0]" class="showcase-timeline-item"><i></i><span><small>{{ event[0] }}</small><strong>{{ event[1] }}</strong></span></div></div></div></div>
                <div class="showcase-next-action"><span><small>{{ screen.noteTitle }}</small><strong>{{ screen.noteValue }}</strong><small>{{ screen.noteMeta }}</small></span><span class="showcase-next-action-icon" aria-hidden="true"><ArrowUpRight :size="16" /></span></div>
              </template>

              <template v-else-if="screen.view === 'table'">
                <div class="showcase-metrics showcase-metrics-three"><div v-for="metric in screen.metrics" :key="metric.label" class="showcase-metric"><span>{{ metric.label }}</span><strong>{{ metric.value }}</strong><small>{{ metric.note }}</small></div></div>
                <div class="showcase-table-wrap showcase-large-table" role="region" tabindex="0" :aria-label="`${screen.appTitle} sample data table`"><div class="showcase-table-title">{{ screen.appTitle }} <span>Filter <ChevronDown :size="12" /></span></div><table class="showcase-table"><thead><tr><th v-for="column in screen.columns" :key="column">{{ column }}</th></tr></thead><tbody><tr v-for="row in screen.rows" :key="row[0]"><td v-for="(cell, cellIndex) in row" :key="cell" :class="statusTone(screen, row, cellIndex)">{{ cell }}</td></tr></tbody></table></div>
                <div class="showcase-next-action"><span><small>{{ screen.noteTitle }}</small><strong>{{ screen.noteValue }}</strong><small>{{ screen.noteMeta }}</small></span><span class="showcase-next-action-icon" aria-hidden="true"><ArrowUpRight :size="16" /></span></div>
              </template>

              <template v-else-if="screen.view === 'workflow'">
                <div class="showcase-workflow-meta"><span><i></i> ACTIVE WORKFLOW</span><span>3.2 sec average run <ArrowUpRight :size="12" /></span></div>
                <div class="showcase-flow-canvas" tabindex="0" aria-label="Workflow steps. Scroll horizontally to follow the complete process"><template v-for="(node, nodeIndex) in screen.nodes" :key="node[1]"><div class="showcase-flow-node"><small>{{ node[0] }}</small><strong>{{ node[1] }}</strong><span>{{ node[2] }}</span><b v-if="nodeIndex === 0">↗</b></div><div v-if="nodeIndex < screen.nodes.length - 1" class="showcase-flow-connector"><i></i><ArrowRight :size="13" /></div></template></div>
                <div class="showcase-branch-note"><span><i></i> CONDITION BRANCH</span><strong>{{ screen.branch }}</strong></div>
                <div class="showcase-next-action"><span><small>{{ screen.noteTitle }}</small><strong>{{ screen.noteValue }}</strong><small>{{ screen.noteMeta }}</small></span><span class="showcase-next-action-icon" aria-hidden="true"><ArrowUpRight :size="16" /></span></div>
              </template>

              <template v-else-if="screen.view === 'insights'">
                <div class="showcase-insight-kpis"><article><span>Signals to review</span><strong>{{ productInsights.length }}</strong><small>Based on sample activity</small></article><article><span>Human decisions</span><strong>In control</strong><small>Suggestions need review</small></article><article><span>Scope</span><strong>{{ page.category.split(' ')[0].toLowerCase() }}</strong><small>Across this workspace</small></article></div>
                <div class="showcase-insight-list"><div class="showcase-insight-heading"><strong>Suggested for your team</strong><span><Sparkles :size="11"/> AI SUGGESTIONS · SAMPLE DATA</span></div><button v-for="(insight, insightIndex) in productInsights" :key="insight.title" class="showcase-insight-card" @click="insightAction(insightIndex)"><span class="showcase-insight-icon" :class="insight.tone"><Sparkles :size="13"/></span><span class="showcase-insight-copy"><small>{{ insight.category }}</small><strong>{{ insight.title }}</strong><em>{{ insight.detail }}</em><b>{{ insight.action }} <ArrowRight :size="11"/></b></span><span class="showcase-insight-impact"><strong>{{ insight.impact }}</strong><small>{{ insight.label }}</small></span></button><div class="showcase-insight-disclaimer"><Check :size="11"/> Recommendations are advisory. Your team reviews and decides what to do.</div></div>
              </template>

              <template v-else-if="screen.view === 'reports'">
                <div class="showcase-report-kpis"><article v-for="metric in page.screens[0].metrics.slice(0, 3)" :key="metric.label"><span>{{ metric.label }}</span><strong>{{ metric.value }}</strong><small>{{ metric.note }}</small></article></div>
                <div class="showcase-report-grid"><section class="showcase-report-chart"><div class="showcase-panel-title"><span>{{ page.screens[0].chartTitle }}</span><small>PERFORMANCE OVER TIME</small></div><div class="showcase-report-bars"><i v-for="(bar, barIndex) in page.screens[0].bars.slice(0, 8)" :key="barIndex" :style="{ '--report-bar-height': `${bar}%`, '--report-bar-delay': `${barIndex * 45}ms` }"></i></div><div class="showcase-chart-axis"><span v-for="label in page.screens[0].chartAxis ?? ['WEEK 01', 'WEEK 02', 'WEEK 03', 'WEEK 04']" :key="label">{{ label }}</span></div></section><section class="showcase-report-breakdown"><div class="showcase-panel-title"><span>Operational breakdown</span><small>{{ page.screens[0].sideRows.length }} items</small></div><div v-for="row in page.screens[0].sideRows" :key="row[0]" class="showcase-report-item"><i class="showcase-status-mark" :class="row[2]"></i><span><strong>{{ row[0] }}</strong><small>{{ row[1] }}</small></span><ArrowUpRight :size="12"/></div></section></div>
                <div class="showcase-report-foot"><span><i></i>Sample records · refreshed just now</span><button @click="setScreen(0)">Open {{ page.screens[0].appTitle }} <ArrowRight :size="11"/></button></div>
              </template>
            </div>
          </div>
          </div>
          </Transition>
        </div>
        <div class="showcase-slider-controls"><div class="showcase-slider-dots"><button v-for="(slide, index) in screens" :key="slide.eyebrow" :aria-label="`Show ${slide.appTitle} screen`" :aria-pressed="activeScreen === index" :class="{ active: activeScreen === index }" @click="setScreen(index)"><i></i></button></div><div class="showcase-slider-actions"><span>{{ screen.appTitle }}</span><button aria-label="Previous screen" @click="setScreen(activeScreen - 1)">‹</button><button aria-label="Next screen" @click="setScreen(activeScreen + 1)">›</button><button :aria-label="pauseRotation ? 'Resume slideshow' : 'Pause slideshow'" @click="pauseRotation = !pauseRotation"><span v-if="pauseRotation">▶</span><span v-else>Ⅱ</span></button></div></div>
        <div class="showcase-pointer-hint"><span>MOVE YOUR POINTER OVER THE INTERFACE</span><i></i>EXPLORE THE WORKSPACE</div>
      </section>
    </main>
  </div>
</template>

<style>
@import './product-showcase.css';
</style>
