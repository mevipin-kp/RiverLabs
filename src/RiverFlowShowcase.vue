<script setup>
import SiteHeader from './SiteHeader.vue'
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { ArrowRight, ArrowUpRight, Check, ChevronDown, Search, Sparkles, Workflow, X } from '@lucide/vue'

const activeSlide = ref(0)
const selectedPeriod = ref(0)
const selectedNode = ref(0)
const selectedException = ref(0)
const reviewedExceptions = reactive(new Set())
const pauseRotation = ref(false)
const workflowPublished = ref(false)
const pointerInside = ref(false)
const focusInside = ref(false)
const pointer = reactive({ x: 0, y: 0 })
let rotationTimer

const slides = [
  { label: 'Overview', heading: 'See work move.\nKnow what needs you.', description: 'Requests move through connected workflows, while your team keeps a clear view of progress, ownership, and exceptions.', section: 'WORKFLOW OVERVIEW' },
  { label: 'Workflow design', heading: 'Design the path.\nKeep people in control.', description: 'Connect routine steps across your tools, with approvals and decisions staying with the right people.', section: 'WORKFLOW DESIGN' },
  { label: 'Exception review', heading: 'Give every exception\na next step.', description: 'Make stalled or unusual runs easy to find, understand, assign, and resolve.', section: 'EXCEPTION REVIEW' },
  { label: 'AI Insights', heading: 'Spot patterns.\nChoose what to do.', description: 'Bring emerging risks, recurring delays, and practical next steps into one reviewable view.', section: 'AI INSIGHTS' },
  { label: 'Reports & dashboards', heading: 'See the operation.\nFind the next improvement.', description: 'Track workflow performance across teams, time periods, and operational outcomes.', section: 'REPORTS & DASHBOARDS' },
]
const workspaceNavigation = [
  { label: 'Overview', icon: '▦', slide: 0 },
  { label: 'Workflows', icon: '⌁', slide: 1 },
  { label: 'Runs & exceptions', icon: '↗', slide: 2, badge: '7' },
  { label: 'AI Insights', icon: '✳', slide: 3, badge: '3' },
  { label: 'Reports & dashboards', icon: '▤', slide: 4 },
]
const workflowNodes = [
  { type: 'TRIGGER', title: 'Invoice received', detail: 'A new invoice enters the finance inbox and starts a tracked workflow.' },
  { type: 'EXTRACT', title: 'Read invoice fields', detail: 'Supplier, invoice number, amount, and due date are gathered for review.' },
  { type: 'MATCH', title: 'Check supplier record', detail: 'The request is matched to a supplier record before it moves forward.' },
  { type: 'APPROVAL', title: 'Manager review', detail: 'The assigned budget owner checks the invoice and records a decision.' },
  { type: 'COMPLETE', title: 'Update finance ledger', detail: 'After approval, the record is updated and the requester is notified.' },
]
const exceptions = [
  { id: 'RUN-248193', workflow: 'Invoice value mismatch', subject: 'Al Noor Supplies · INV-20481', reason: 'Invoice total differs from the claimed amount', owner: 'Finance team', time: '10:43 AM', priority: 'AI flagged', confidence: '98%', evidence: 'Claimed amount AED 8,450 · Invoice total AED 8,150 · Difference AED 300', suggestion: 'Compare the invoice against its purchase order before approval.', tone: 'amber' },
  { id: 'RUN-248185', workflow: 'Possible duplicate invoice', subject: 'Al Noor Supplies · INV-20481', reason: 'This invoice may already be recorded', owner: 'Finance team', time: '10:18 AM', priority: 'AI flagged', confidence: '96%', evidence: 'Similar invoice INV-20377 from the same supplier was paid on 07 May.', suggestion: 'Check the earlier payment and confirm this is not a resubmission.', tone: 'amber' },
  { id: 'RUN-248167', workflow: 'Supplier detail changed', subject: 'Cedar Works · Supplier profile', reason: 'Payment details differ from the last approved record', owner: 'Finance team', time: '09:52 AM', priority: 'Verify details', confidence: 'Review', evidence: 'The bank account on this request does not match the supplier’s last approved account.', suggestion: 'Verify the change with the supplier using a known contact before payment.', tone: 'red' },
  { id: 'RUN-248152', workflow: 'Delivery quantity mismatch', subject: 'ORD-82418 · Downtown', reason: 'Delivered quantity is below the order quantity', owner: 'Retail operations', time: '09:31 AM', priority: 'AI flagged', confidence: '93%', evidence: 'Purchase order: 48 units · Delivery note: 42 units · Difference: 6 units', suggestion: 'Review the delivery note and record a partial receipt or request clarification.', tone: 'amber' },
  { id: 'RUN-248141', workflow: 'New starter setup', subject: 'Mariam A. · Operations', reason: 'A required start date is missing', owner: 'People team', time: '09:14 AM', priority: 'Needs information', evidence: 'The start date is required before payroll and access setup can continue.', suggestion: 'Ask the hiring manager to confirm the start date.', tone: 'blue' },
]
const attentionItems = [
  { title: 'Invoice amount mismatch', detail: 'AED 8,450 claimed · AED 8,150 on invoice', exception: 0, tone: 'red' },
  { title: 'Possible duplicate invoice', detail: 'Similar invoice already paid · 96% match', exception: 1, tone: 'amber' },
  { title: 'Supplier bank detail changed', detail: 'Verify before releasing payment', exception: 2, tone: 'red' },
]
const activeException = computed(() => exceptions[selectedException.value])
const chartValues = computed(() => selectedPeriod.value === 0 ? [35, 51, 43, 70, 59, 78, 66, 88, 73, 96, 77, 90] : [58, 42, 67, 48, 83, 61, 72, 54, 91, 65, 80, 100])
const reportRows = computed(() => selectedPeriod.value === 0
  ? [['Invoice processing', 41, '3,492'], ['Order validation', 31, '2,608'], ['New starter setup', 16, '1,384'], ['Supplier onboarding', 12, '1,008']]
  : [['Invoice processing', 40, '14,092'], ['Order validation', 30, '10,480'], ['New starter setup', 16, '5,536'], ['Supplier onboarding', 14, '4,708']])
const metrics = computed(() => selectedPeriod.value === 0
  ? [{ label: 'Active workflows', value: '24', note: 'Across 6 teams' }, { label: 'Runs completed', value: '8,492', note: 'This week' }, { label: 'Needs review', value: '07', note: 'Across 3 workflows' }, { label: 'Time returned', value: '316 hrs', note: 'Estimated this month' }]
  : [{ label: 'Active workflows', value: '24', note: 'Across 6 teams' }, { label: 'Runs completed', value: '34,816', note: 'This month' }, { label: 'Needs review', value: '12', note: 'Across 5 workflows' }, { label: 'Time returned', value: '1,284 hrs', note: 'Estimated this quarter' }])
const tiltStyle = computed(() => ({
  '--flow-tilt-x': `${pointer.y * -2.8}deg`,
  '--flow-tilt-y': `${pointer.x * 3.8}deg`,
  '--flow-shift-x': `${pointer.x * 5}px`,
  '--flow-shift-y': `${pointer.y * -4}px`,
}))

function setSlide(index) { activeSlide.value = (index + slides.length) % slides.length }
function onPointerMove(event) {
  const bounds = event.currentTarget.getBoundingClientRect()
  pointer.x = ((event.clientX - bounds.left) / bounds.width - 0.5) * 2
  pointer.y = ((event.clientY - bounds.top) / bounds.height - 0.5) * 2
}
function resetPointer() { pointer.x = 0; pointer.y = 0; pointerInside.value = false }
function onFocusOut(event) { if (!event.currentTarget.contains(event.relatedTarget)) focusInside.value = false }
function toggleReviewed() { reviewedExceptions.has(selectedException.value) ? reviewedExceptions.delete(selectedException.value) : reviewedExceptions.add(selectedException.value) }

onMounted(() => {
  document.title = 'River Flow | RiverLabs'
  if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    rotationTimer = window.setInterval(() => {
      if (!pauseRotation.value && !pointerInside.value && !focusInside.value && document.visibilityState === 'visible') setSlide(activeSlide.value + 1)
    }, 9000)
  }
})
onUnmounted(() => window.clearInterval(rotationTimer))
</script>

<template>
  <div class="river-flow-showcase">
    <SiteHeader mode="subpage" />

    <main class="flow-showcase-main">
      <section class="flow-story" aria-label="RiverFlow product overview">
        <div class="flow-story-copy">
          <div class="flow-eyebrow"><i></i>WORKFLOW &amp; PROCESS AUTOMATION</div>
          <h1>Make repeatable<br/>work visible and<br/><span>dependable.</span></h1>
          <p>Route requests, track each run, and give your team a clear path through exceptions.</p>
          <ul class="flow-value-list"><li><Check :size="14"/> Routine work follows a clear path</li><li><Check :size="14"/> People stay in control of decisions</li><li><Check :size="14"/> Exceptions come with context</li></ul>
          <div class="flow-story-actions"><a href="/contact?product=river-flow" class="flow-primary-cta">Discuss RiverFlow <ArrowRight :size="16" /></a><span>BUILT AROUND YOUR PROCESSES</span></div>
        </div>
        <div class="flow-story-foot"><span>RIVERFLOW</span><i></i><span>PRODUCT PREVIEW</span></div>
      </section>

      <section class="flow-product-slider" aria-label="RiverFlow interface slideshow" @pointerenter="pointerInside = true" @pointerleave="resetPointer" @focusin="focusInside = true" @focusout="onFocusOut">
        <div class="flow-slider-intro"><div><span>INSIDE RIVERFLOW</span><h2>{{ slides[activeSlide].section }}</h2></div><div class="flow-slide-count"><strong>0{{ activeSlide + 1 }}</strong><i></i><span>0{{ slides.length }}</span></div></div>
        <div class="flow-device-stage" :class="{ 'flow-pointer-active': pointerInside }" @pointermove="onPointerMove">
          <Transition name="flow-screen" mode="out-in" appear>
            <div :key="activeSlide" class="flow-device" :style="tiltStyle">
              <div class="flow-window-top"><div class="flow-window-dots"><i></i><i></i><i></i></div><span>riverflow.app <i>/</i> {{ slides[activeSlide].label }}</span><span class="flow-window-user">RL</span></div>
              <div class="flow-app-layout">
                <aside class="flow-app-sidebar"><div class="flow-app-logo"><span><Workflow :size="15"/></span><strong>RiverFlow</strong></div><small class="flow-app-label">WORKSPACE</small><button v-for="nav in workspaceNavigation" :key="nav.label" :class="{ selected: nav.slide === activeSlide }" :aria-current="nav.slide === activeSlide ? 'page' : undefined" @click="setSlide(nav.slide)"><span>{{ nav.icon }}</span><span class="flow-nav-label">{{ nav.label }}</span><b v-if="nav.badge">{{ nav.badge }}</b></button><div class="flow-sidebar-foot"><i></i>All systems operational</div></aside>
                <div class="flow-app-page">
                  <div class="flow-app-toolbar"><div class="flow-app-search"><Search :size="13"/><span>Search workflows and runs</span><kbd>⌘ K</kbd></div><span class="flow-toolbar-avatar">JD</span></div>

                  <template v-if="activeSlide === 0">
                    <div class="flow-app-page-heading"><div><small>MONDAY, 18 MAY 2026</small><h3>Good morning, Jordan</h3><p>Here’s the latest across your workflows.</p></div><button class="flow-date-button" @click="selectedPeriod = selectedPeriod === 0 ? 1 : 0">{{ selectedPeriod === 0 ? 'This week' : 'This month' }} <ChevronDown :size="12"/></button></div>
                    <div class="flow-kpi-grid"><article v-for="metric in metrics" :key="metric.label" class="flow-kpi"><span>{{ metric.label }}</span><strong>{{ metric.value }}</strong><small>{{ metric.note }}</small></article></div>
                    <div class="flow-overview-grid"><section class="flow-chart-card"><div class="flow-panel-heading"><strong>Workflow activity</strong><span>{{ selectedPeriod === 0 ? 'RUNS / DAY' : 'RUNS / WEEK' }}</span></div><div class="flow-chart"><div class="flow-chart-grid"><i></i><i></i><i></i></div><span v-for="(bar, index) in chartValues" :key="`${selectedPeriod}-${index}`" class="flow-chart-bar" :style="{ '--bar-height': `${bar}%`, '--bar-delay': `${index * 35}ms` }"></span></div><div class="flow-chart-labels"><span>{{ selectedPeriod === 0 ? 'MON' : 'WEEK 1' }}</span><span>{{ selectedPeriod === 0 ? 'WED' : 'WEEK 2' }}</span><span>{{ selectedPeriod === 0 ? 'FRI' : 'WEEK 3' }}</span><span>{{ selectedPeriod === 0 ? 'SUN' : 'WEEK 4' }}</span></div></section><section class="flow-attention-card"><div class="flow-panel-heading"><strong>AI suggestions</strong><span class="flow-ai-label"><Sparkles :size="9"/> 03</span></div><button v-for="item in attentionItems" :key="item.title" class="flow-attention-row" @click="selectedException = item.exception; setSlide(2)"><i :class="item.tone"></i><span><b>{{ item.title }}</b><small>{{ item.detail }}</small></span><ArrowUpRight :size="13"/></button></section></div>
                    <div class="flow-recent-runs"><div class="flow-panel-heading"><strong>Recent runs</strong><button @click="setSlide(2)">View exceptions <ArrowRight :size="12"/></button></div><div class="flow-run-row"><span class="flow-run-icon"><Check :size="12"/></span><span><b>Invoice processing</b><small>INV-20479 · Finance</small></span><span class="flow-run-state complete">Completed</span><time>2 min ago</time></div><div class="flow-run-row"><span class="flow-run-icon"><Check :size="12"/></span><span><b>Order validation</b><small>ORD-82416 · Retail ops</small></span><span class="flow-run-state complete">Completed</span><time>8 min ago</time></div></div>
                  </template>

                  <template v-else-if="activeSlide === 1">
                    <div class="flow-app-page-heading"><div><small>WORKFLOWS / INVOICE PROCESSING</small><h3>Invoice approval</h3><p>Version 3 · Updated 15 May by A. Rahman</p></div><span class="flow-published"><i></i>Active</span></div>
                    <div class="flow-builder-toolbar"><span><b>{{ workflowPublished ? 'Version 4' : 'Draft changes' }}</b> {{ workflowPublished ? 'published just now' : 'are saved automatically' }}</span><button @click="workflowPublished = !workflowPublished">{{ workflowPublished ? 'Published' : 'Publish changes' }} <component :is="workflowPublished ? Check : ArrowUpRight" :size="12"/></button></div>
                    <div class="flow-builder-layout"><div class="flow-canvas"><div class="flow-canvas-grid"></div><div class="flow-canvas-nodes"><template v-for="(node, index) in workflowNodes" :key="node.title"><button class="flow-node" :class="{ focused: selectedNode === index }" @click="selectedNode = index"><small>{{ node.type }}</small><strong>{{ node.title }}</strong><span>{{ node.detail }}</span><i v-if="index === selectedNode"><Check :size="11"/></i></button><div v-if="index < workflowNodes.length - 1" class="flow-node-connector"><span></span><ArrowRight :size="13"/></div></template></div><div class="flow-branch-chip">IF AMOUNT EXCEEDS AED 5,000 <ArrowRight :size="11"/> FINANCE DIRECTOR</div></div><aside class="flow-node-inspector"><small>STEP {{ String(selectedNode + 1).padStart(2, '0') }} / {{ workflowNodes.length }}</small><h4>{{ workflowNodes[selectedNode].title }}</h4><p>{{ workflowNodes[selectedNode].detail }}</p><div class="flow-inspector-field"><span>Step type</span><b>{{ workflowNodes[selectedNode].type }}</b></div><div class="flow-inspector-field"><span>Owner</span><b>{{ selectedNode === 3 ? 'Budget owner' : 'RiverFlow' }}</b></div><span class="flow-inspector-link">Step settings <ArrowUpRight :size="11"/></span></aside></div>
                    <div class="flow-builder-footer"><span><i></i>All changes saved</span><span>Last test run · 10:32 AM <Check :size="12"/></span></div>
                  </template>

                  <template v-else-if="activeSlide === 2">
                    <div class="flow-app-page-heading"><div><small>RUNS / EXCEPTIONS</small><h3>Needs your attention</h3><p>Review a run to see what happened and what comes next.</p></div><span class="flow-exception-count">7 open</span></div>
                    <div class="flow-exception-layout"><div class="flow-exception-list"><div class="flow-exception-list-head"><span>OPEN EXCEPTIONS</span><span>{{ exceptions.length }} shown</span></div><button v-for="(exception, index) in exceptions" :key="exception.id" class="flow-exception-item" :class="{ selected: index === selectedException }" @click="selectedException = index"><span class="flow-exception-dot" :class="{ reviewed: reviewedExceptions.has(index) }"></span><span><small>{{ exception.id }} · {{ exception.time }}</small><strong>{{ exception.workflow }}</strong><em>{{ exception.subject }}</em><span class="flow-exception-tag" :class="{ reviewed: reviewedExceptions.has(index) }">{{ reviewedExceptions.has(index) ? 'Reviewed' : exception.priority }}</span></span><ArrowUpRight :size="12"/></button></div><div class="flow-exception-detail"><div class="flow-detail-head"><span class="flow-detail-alert" :class="`tone-${activeException.tone}`"><Sparkles v-if="activeException.confidence" :size="12"/><X v-else :size="12"/></span><span><small>{{ activeException.id }} · {{ activeException.time }}</small><b>{{ activeException.reason }}</b></span></div><div class="flow-detail-facts"><span>Workflow<strong>{{ activeException.workflow }}</strong></span><span>Record<strong>{{ activeException.subject }}</strong></span><span>Assigned to<strong>{{ activeException.owner }}</strong></span><span>Signal strength<strong>{{ activeException.confidence || 'Required field' }}</strong></span></div><div v-if="activeException.confidence" class="flow-ai-evidence"><div><Sparkles :size="11"/><small>AI FLAG · HUMAN REVIEW</small><b>{{ activeException.evidence }}</b></div></div><div class="flow-detail-event"><i></i><span><small>{{ activeException.confidence ? 'SUGGESTED NEXT STEP' : 'WHY THIS IS PAUSED' }}</small><b>{{ activeException.suggestion }}</b></span></div><button class="flow-review-button" @click="toggleReviewed"><Check :size="13"/>{{ reviewedExceptions.has(selectedException) ? 'Reopen for review' : 'Mark reviewed' }}</button></div></div>
                    <div class="flow-exception-layout"><div class="flow-exception-list"><div class="flow-exception-list-head"><span>OPEN EXCEPTIONS</span><span>{{ exceptions.length }} shown</span></div><button v-for="(exception, index) in exceptions" :key="exception.id" class="flow-exception-item" :class="{ selected: index === selectedException }" @click="selectedException = index"><span class="flow-exception-dot" :class="{ reviewed: reviewedExceptions.has(index) }"></span><span><small>{{ exception.id }} · {{ exception.time }}</small><strong>{{ exception.workflow }}</strong><em>{{ exception.subject }}</em><span class="flow-exception-tag" :class="{ reviewed: reviewedExceptions.has(index) }">{{ reviewedExceptions.has(index) ? 'Reviewed' : exception.priority }}</span></span><ArrowUpRight :size="12"/></button></div><div class="flow-exception-detail"><div class="flow-detail-head"><span class="flow-detail-alert" :class="`tone-${activeException.tone}`"><Sparkles v-if="activeException.confidence" :size="12"/><X v-else :size="12"/></span><span><small>{{ activeException.id }} · {{ activeException.time }}</small><b>{{ activeException.reason }}</b></span></div><div class="flow-detail-facts"><span>Workflow<strong>{{ activeException.workflow }}</strong></span><span>Record<strong>{{ activeException.subject }}</strong></span><span>Assigned to<strong>{{ activeException.owner }}</strong></span><span>Signal strength<strong>{{ activeException.confidence || 'Required field' }}</strong></span></div><div v-if="activeException.confidence" class="flow-ai-evidence"><div><Sparkles :size="11"/><small>AI FLAG · HUMAN REVIEW</small><b>{{ activeException.evidence }}</b></div></div><div class="flow-detail-event"><i></i><span><small>{{ activeException.confidence ? 'SUGGESTED NEXT STEP' : 'WHY THIS IS PAUSED' }}</small><b>{{ activeException.suggestion }}</b></span></div><button class="flow-review-button" @click="toggleReviewed"><Check :size="13"/>{{ reviewedExceptions.has(selectedException) ? 'Reopen for review' : 'Mark reviewed' }}</button></div></div>
                  </template>

                  <template v-else-if="activeSlide === 3">
                    <div class="flow-app-page-heading"><div><small>INTELLIGENCE / TEAM WORKSPACE</small><h3>AI insights</h3><p>Signals from completed runs, open requests, and connected records.</p></div><span class="flow-ai-summary"><Sparkles :size="10"/> 3 new</span></div>
                    <div class="flow-insight-summary"><div><span>Potential time returned</span><strong>42 hrs <small>/ month</small></strong></div><div><span>Patterns to review</span><strong>03 <small>this week</small></strong></div><div><span>Suggested actions</span><strong>08 <small>for your team</small></strong></div></div>
                    <div class="flow-insight-list"><div class="flow-insight-list-head"><strong>Suggested for Finance</strong><button @click="setSlide(2)">Review all <ArrowRight :size="11"/></button></div>
                      <button class="flow-insight-card" @click="selectedException = 0; setSlide(2)"><span class="flow-insight-icon amber"><Sparkles :size="13"/></span><span class="flow-insight-copy"><small>INVOICE PROCESSING · 98% SIGNAL</small><strong>Invoice value differs from the submitted amount</strong><em>3 invoices this month show a variance between the claimed and document totals.</em><b>Review the AED 300 variance <ArrowRight :size="11"/></b></span><span class="flow-insight-impact">AED 12.4k<small>needs review</small></span></button>
                      <button class="flow-insight-card" @click="setSlide(1)"><span class="flow-insight-icon blue"><Sparkles :size="13"/></span><span class="flow-insight-copy"><small>PROCESS PATTERN · 91% SIGNAL</small><strong>Approval waits cluster at the same step</strong><em>Most invoice delays happen while budget owners are awaiting supporting documents.</em><b>See the workflow <ArrowRight :size="11"/></b></span><span class="flow-insight-impact">1.8 days<small>median wait</small></span></button>
                      <div class="flow-insight-note"><Check :size="11"/> Suggestions are advisory. Your team reviews and decides what to do.</div>
                    </div>
                  </template>

                  <template v-else>
                    <div class="flow-app-page-heading"><div><small>ANALYTICS / OPERATIONS</small><h3>Reports &amp; dashboards</h3><p>Workflow performance across your connected teams.</p></div><button class="flow-date-button" @click="selectedPeriod = selectedPeriod === 0 ? 1 : 0">{{ selectedPeriod === 0 ? 'This month' : 'This quarter' }} <ChevronDown :size="12"/></button></div>
                    <div class="flow-report-kpis"><article><span>Successful runs</span><strong>{{ selectedPeriod === 0 ? '8,492' : '34,816' }}</strong><small><i>↑ 12.8%</i> vs previous period</small></article><article><span>Average completion</span><strong>3.4 min</strong><small><i>↓ 18%</i> vs previous period</small></article><article><span>Exception rate</span><strong>2.1%</strong><small><i>↓ 0.6%</i> vs previous period</small></article></div>
                    <div class="flow-report-grid"><section class="flow-report-chart"><div class="flow-panel-heading"><strong>Runs by workflow</strong><span>COMPLETED / {{ selectedPeriod === 0 ? 'MONTH' : 'QUARTER' }}</span></div><div class="flow-report-bars"><div v-for="row in reportRows" :key="row[0]" class="flow-report-bar-row"><span>{{ row[0] }}</span><i><b :style="{ width: `${row[1]}%` }"></b></i><strong>{{ row[2] }}</strong></div></div></section><section class="flow-report-outcomes"><div class="flow-panel-heading"><strong>Operational outcomes</strong><span>THIS PERIOD</span></div><div><span>Time returned to teams</span><strong>{{ selectedPeriod === 0 ? '316 hrs' : '1,284 hrs' }}</strong></div><div><span>Runs needing a person</span><strong>7.4%</strong></div><div><span>Connected workflows</span><strong>24</strong></div><button @click="setSlide(0)">View workspace overview <ArrowRight :size="11"/></button></section></div>
                    <div class="flow-report-footer"><span><i></i>Data refreshed 8 minutes ago</span><span>Filter by team <ChevronDown :size="10"/></span></div>
                  </template>
                  <div class="flow-app-status"><span><i></i>Connected workspace</span><span>Sample data · Secure preview</span></div>
                </div>
              </div>
            </div>
          </Transition>
        </div>
        <div class="flow-slider-controls"><div class="flow-slider-dots"><button v-for="(slide, index) in slides" :key="slide.label" :aria-label="`Show ${slide.label} screen`" :aria-pressed="activeSlide === index" :class="{ active: activeSlide === index }" @click="setSlide(index)"><i></i></button></div><div class="flow-slider-actions"><span>{{ slides[activeSlide].label }}</span><button aria-label="Previous screen" @click="setSlide(activeSlide - 1)">‹</button><button aria-label="Next screen" @click="setSlide(activeSlide + 1)">›</button><button :aria-label="pauseRotation ? 'Resume slideshow' : 'Pause slideshow'" @click="pauseRotation = !pauseRotation"><span v-if="pauseRotation">▶</span><span v-else>Ⅱ</span></button></div></div>
        <div class="flow-product-pointer-hint"><span>MOVE YOUR POINTER OVER THE INTERFACE</span><i></i>EXPLORE THE WORKSPACE</div>
      </section>
    </main>
  </div>
</template>

<style>
@import './river-flow-showcase.css';
</style>
