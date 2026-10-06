<script setup>
import SiteHeader from './SiteHeader.vue'
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { ArrowDown, ArrowRight, ArrowUpRight, Check, ChevronRight, CircleCheck, Network, Search, Sparkles, Workflow } from '@lucide/vue'

const aiStep = ref(2)
const aiRuns = ref(1284)
const odooStep = ref(1)
const odooPaused = ref(false)
const activeSystem = ref('Finance')
const visibleSections = ref(new Set())
const reducedMotion = ref(false)
let observer
let odooTimer
let aiTimer

const odooStages = [
  { name: 'Opportunity', detail: 'A qualified lead enters the sales pipeline.', owner: 'CRM · Sales team', status: 'Ready for quotation' },
  { name: 'Quotation', detail: 'Approved products, pricing, and terms are assembled.', owner: 'Sales · Price list applied', status: 'Awaiting customer' },
  { name: 'Sales order', detail: 'A confirmed quote reserves stock and starts fulfilment.', owner: 'Inventory · Stock reserved', status: 'Ready to deliver' },
  { name: 'Invoice', detail: 'Delivery updates the invoice and receivables workflow.', owner: 'Accounting · Draft prepared', status: 'Ready for review' },
]
const erpSystems = [
  { name: 'Finance', code: 'FIN', detail: 'Ledger, payables & receivables', tone: 'blue' },
  { name: 'Operations', code: 'OPS', detail: 'Orders, inventory & delivery', tone: 'navy' },
  { name: 'People', code: 'HR', detail: 'Teams, roles & approvals', tone: 'steel' },
  { name: 'Customer data', code: 'CRM', detail: 'Accounts, service & history', tone: 'sky' },
]
const activeOdooStage = computed(() => odooStages[odooStep.value])

function setOdooStep(index) { odooStep.value = index }
function runAutomation() { aiStep.value = (aiStep.value + 1) % 5; aiRuns.value += 1 }
function selectSystem(name) { activeSystem.value = name }

onMounted(() => {
  document.title = 'Our Expertise | RiverLabs'
  reducedMotion.value = window.matchMedia('(prefers-reduced-motion: reduce)').matches
  if (reducedMotion.value || !('IntersectionObserver' in window)) {
    visibleSections.value = new Set(['ai-automation', 'odoo-implementation', 'erp-solutions'])
    return
  }
  observer = new IntersectionObserver(entries => {
    for (const entry of entries) {
      if (entry.isIntersecting) visibleSections.value = new Set([...visibleSections.value, entry.target.id])
    }
  }, { threshold: .18 })
  document.querySelectorAll('.expertise-section').forEach(section => observer.observe(section))
  const sectionId = window.location.hash.slice(1)
  if (sectionId) requestAnimationFrame(() => document.getElementById(sectionId)?.scrollIntoView({ behavior: reducedMotion.value ? 'auto' : 'smooth', block: 'start' }))
  if (!reducedMotion.value) {
    odooTimer = window.setInterval(() => { if (!odooPaused.value && document.visibilityState === 'visible') odooStep.value = (odooStep.value + 1) % odooStages.length }, 4600)
    aiTimer = window.setInterval(() => { if (document.visibilityState === 'visible') { aiStep.value = (aiStep.value + 1) % 5; if (aiStep.value === 0) aiRuns.value += 1 } }, 2600)
  }
})
onUnmounted(() => { observer?.disconnect(); window.clearInterval(odooTimer); window.clearInterval(aiTimer) })
</script>

<template>
  <div class="expertise-page">
    <SiteHeader mode="subpage" />

    <main>
      <section id="ai-automation" class="expertise-section expertise-ai" :class="{ 'is-visible': visibleSections.has('ai-automation') }">
        <div class="expertise-copy expertise-copy-left">
          <div class="expertise-kicker"><span>01</span><i></i> INTELLIGENT AUTOMATION</div>
          <h1>AI that moves<br/>work forward.</h1>
          <p>Put AI to work on the repetitive steps that slow your team down—from understanding incoming information to preparing the next action.</p>
          <ul class="expertise-points"><li><Check :size="14"/> Read and classify documents and requests</li><li><Check :size="14"/> Bring relevant records together for context</li><li><Check :size="14"/> Route exceptions to people for a decision</li></ul>
          <a class="expertise-cta" href="/contact?product=AI%20Automation">Discuss AI Automation <ArrowRight :size="15"/></a>
          <div class="expertise-scroll-note"><span>01 / 03</span><i></i><span>SCROLL TO EXPLORE</span><ArrowDown :size="12"/></div>
        </div>
        <div class="expertise-art expertise-ai-art" aria-label="Animated AI-assisted invoice workflow preview">
          <div class="expertise-art-head"><div><span>RIVERLABS / AI AUTOMATION</span><strong>Invoice intake workflow</strong></div><span class="expertise-live"><i></i> WORKFLOW ACTIVE</span></div>
          <div class="ai-workspace">
            <div class="ai-workspace-toolbar"><span><Search :size="13"/> Finance workspace</span><span>Sample run · {{ aiRuns.toLocaleString() }}</span></div>
            <div class="ai-flow-area">
              <div class="ai-flow-rail"><span></span><i></i><i></i><i></i><i></i><i></i></div>
              <div class="ai-flow-nodes">
                <div class="ai-flow-node" :class="{ active: aiStep === 0 }"><span class="ai-node-icon inbox-icon">↓</span><span><small>TRIGGER</small><strong>Invoice received</strong><em>Al Noor Supplies · PDF</em></span><b>New</b></div>
                <div class="ai-flow-node" :class="{ active: aiStep === 1 }"><span class="ai-node-icon spark-icon"><Sparkles :size="15"/></span><span><small>AI EXTRACTION</small><strong>Read invoice details</strong><em>Supplier · amount · due date</em></span><b>9 fields</b></div>
                <div class="ai-flow-node ai-flow-alert" :class="{ active: aiStep === 2 }"><span class="ai-node-icon alert-icon">!</span><span><small>AI CHECK · NEEDS REVIEW</small><strong>Amount variance found</strong><em>Claimed AED 8,450 · invoice AED 8,150</em></span><b>AED 300</b></div>
                <div class="ai-flow-node" :class="{ active: aiStep === 3 }"><span class="ai-node-icon approval-icon">✓</span><span><small>HUMAN DECISION</small><strong>Finance approval</strong><em>Review before the workflow continues</em></span><b>Pending</b></div>
                <div class="ai-flow-node" :class="{ active: aiStep === 4 }"><span class="ai-node-icon complete-icon">↗</span><span><small>CONNECTED ACTION</small><strong>Update finance record</strong><em>After approval is recorded</em></span><b>Ready</b></div>
              </div>
              <aside class="ai-run-inspector"><div class="ai-inspector-top"><span><Sparkles :size="13"/> AI REVIEW</span><b>Sample</b></div><strong>Amount needs a second look</strong><p>The submitted amount does not match the invoice total.</p><div class="ai-amount-compare"><span>Submitted<strong>AED 8,450</strong></span><i>≠</i><span>Invoice<strong>AED 8,150</strong></span></div><div class="ai-confidence"><span>Signal strength</span><b>High</b></div><button @click="runAutomation">Simulate next run <ArrowRight :size="12"/></button><small class="ai-human-note">A person reviews before any payment action.</small></aside>
              <div class="ai-stream-status"><span><i></i>Connected to finance workspace</span><span>Decision stays with your team</span></div>
            </div>
          </div>
          <div class="expertise-floating-tag ai-tag-one"><Sparkles :size="13"/> Context-aware checks</div><div class="expertise-floating-tag ai-tag-two"><CircleCheck :size="13"/> Human approval retained</div>
        </div>
      </section>

      <section id="odoo-implementation" class="expertise-section expertise-odoo" :class="{ 'is-visible': visibleSections.has('odoo-implementation') }">
        <div class="expertise-art expertise-odoo-art" aria-label="Interactive Odoo implementation screens and connected workflow" @pointerenter="odooPaused = true" @pointerleave="odooPaused = false" @focusin="odooPaused = true" @focusout="event => { if (!event.currentTarget.contains(event.relatedTarget)) odooPaused = false }">
          <div class="odoo-window">
            <div class="odoo-window-bar"><span class="odoo-window-brand"><i>o</i> odoo</span><span>Sales / Orders / SO02418</span><span class="odoo-user">RL</span></div>
            <div class="odoo-app-shell">
              <aside class="odoo-sidebar"><span class="odoo-app-name">Sales</span><button class="selected"><i>◫</i> Quotations</button><button><i>▦</i> Orders</button><button><i>◷</i> Activities</button><div class="odoo-sidebar-foot"><i></i> Connected</div></aside>
              <div class="odoo-screen"><div class="odoo-screen-toolbar"><span>Sales Order <b>SO02418</b></span><button>Send by Email <ChevronRight :size="11"/></button></div><div class="odoo-order-title"><div><small>CONFIRMED ORDER</small><h3>Northstar Group</h3><p>Dubai · Commercial fit-out supplies</p></div><span><i></i> {{ activeOdooStage.status }}</span></div>
                <div class="odoo-order-metrics"><div><small>ORDER TOTAL</small><strong>AED 24,860</strong></div><div><small>DELIVERY</small><strong>Dubai South</strong></div><div><small>INVOICE</small><strong>Draft ready</strong></div></div>
                <div class="odoo-flow-title"><strong>Order-to-cash flow</strong><span>CONNECTED APPS</span></div>
                <div class="odoo-flow-track"><template v-for="(stage, index) in odooStages" :key="stage.name"><button class="odoo-flow-step" :class="{ active: odooStep === index, complete: index < odooStep }" @click="setOdooStep(index)"><i>{{ index < odooStep ? '✓' : `0${index + 1}` }}</i><span><strong>{{ stage.name }}</strong><small>{{ ['CRM', 'SALES', 'INVENTORY', 'ACCOUNTING'][index] }}</small></span></button><span v-if="index < odooStages.length - 1" class="odoo-flow-connector" :class="{ passed: index < odooStep }"><i></i></span></template></div>
                <div class="odoo-detail-row"><span><small>{{ activeOdooStage.owner }}</small><strong>{{ activeOdooStage.detail }}</strong></span><span class="odoo-detail-status"><i></i>{{ activeOdooStage.status }}</span></div>
                <div class="odoo-record-table"><div><span>PRODUCT</span><span>QTY</span><span>STATUS</span></div><div><strong>Modular workbench · MW-440</strong><span>12</span><b>Available</b></div><div><strong>Fit-out service · SV-120</strong><span>1</span><b>Scheduled</b></div></div>
              </div>
            </div>
          </div>
          <div class="expertise-floating-tag odoo-tag-one"><span>CRM</span><ArrowRight :size="12"/><span>Sales</span><ArrowRight :size="12"/><span>Inventory</span></div>
          <div class="odoo-process-caption"><span>ONE FLOW OF WORK</span><i></i><span>ONE CONNECTED RECORD</span></div>
        </div>
        <div class="expertise-copy expertise-copy-right">
          <div class="expertise-kicker"><span>02</span><i></i> BUSINESS SYSTEM IMPLEMENTATION</div>
          <h2>Odoo, shaped<br/>around your work.</h2>
          <p>Implement the Odoo apps you need, configured to match how your teams sell, deliver, account, and support customers.</p>
          <ul class="expertise-points"><li><Check :size="14"/> Map existing processes before configuration</li><li><Check :size="14"/> Connect apps around shared business records</li><li><Check :size="14"/> Prepare data, roles, and teams for adoption</li></ul>
          <a class="expertise-cta" href="/contact?product=Odoo%20Implementation">Discuss Odoo Implementation <ArrowRight :size="15"/></a>
          <div class="expertise-scroll-note"><span>02 / 03</span><i></i><span>SCROLL TO EXPLORE</span><ArrowDown :size="12"/></div>
        </div>
      </section>

      <section id="erp-solutions" class="expertise-section expertise-erp" :class="{ 'is-visible': visibleSections.has('erp-solutions') }">
        <div class="expertise-copy expertise-copy-left">
          <div class="expertise-kicker"><span>03</span><i></i> ENTERPRISE SYSTEMS</div>
          <h2>Make your systems<br/>work as one.</h2>
          <p>Connect the platforms, data, and teams your business depends on. Build a reliable operational picture without forcing every team into the same tool.</p>
          <ul class="expertise-points"><li><Check :size="14"/> Integrate core systems around shared processes</li><li><Check :size="14"/> Improve visibility across teams and operations</li><li><Check :size="14"/> Keep ownership, access, and governance clear</li></ul>
          <a class="expertise-cta" href="/contact?product=ERP%20Solutions">Discuss ERP Solutions <ArrowRight :size="15"/></a>
          <div class="expertise-scroll-note"><span>03 / 03</span><i></i><span>BUILT AROUND YOUR BUSINESS</span></div>
        </div>
        <div class="expertise-art expertise-erp-art" aria-label="Animated enterprise systems connection map">
          <div class="erp-visual-top"><span>CONNECTED OPERATIONS</span><div><i></i> SYNC HEALTHY</div></div>
          <div class="erp-map">
            <svg class="erp-connectors" viewBox="0 0 700 500" preserveAspectRatio="none" aria-hidden="true"><path d="M350 250 C260 220 220 135 125 105"/><path d="M350 250 C440 215 480 135 575 105"/><path d="M350 250 C255 285 220 370 125 395"/><path d="M350 250 C445 290 485 365 575 395"/><path d="M125 105 C240 70 460 70 575 105"/><path d="M125 395 C240 430 460 430 575 395"/><circle class="erp-packet packet-a" r="4"><animateMotion v-if="!reducedMotion" dur="3.8s" repeatCount="indefinite" path="M350 250 C260 220 220 135 125 105"/></circle><circle class="erp-packet packet-b" r="4"><animateMotion v-if="!reducedMotion" dur="4.5s" repeatCount="indefinite" path="M575 105 C480 135 440 215 350 250"/></circle><circle class="erp-packet packet-c" r="4"><animateMotion v-if="!reducedMotion" dur="4.2s" repeatCount="indefinite" path="M125 395 C220 370 255 285 350 250"/></circle><circle class="erp-packet packet-d" r="4"><animateMotion v-if="!reducedMotion" dur="4.8s" repeatCount="indefinite" path="M350 250 C445 290 485 365 575 395"/></circle></svg>
            <button v-for="system in erpSystems" :key="system.name" class="erp-system-node" :class="[system.tone, `erp-node-${system.code.toLowerCase()}`, { selected: activeSystem === system.name }]" @click="selectSystem(system.name)"><span class="erp-system-glyph">{{ system.code }}</span><span><strong>{{ system.name }}</strong><small>{{ system.detail }}</small></span><i></i></button>
            <div class="erp-core"><span class="erp-core-mark"><Network :size="20"/></span><small>RIVERLABS</small><strong>Shared data<br/>&amp; integration layer</strong><span class="erp-core-status"><i></i> Events in sync</span></div>
          </div>
          <div class="erp-system-detail"><span><i></i> SELECTED SYSTEM</span><strong>{{ activeSystem }}</strong><small>{{ erpSystems.find(system => system.name === activeSystem)?.detail }}</small><button @click="selectSystem(erpSystems[(erpSystems.findIndex(system => system.name === activeSystem) + 1) % erpSystems.length].name)">Explore connected systems <ArrowRight :size="12"/></button></div>
          <div class="erp-map-legend"><span><i></i> Business records</span><span><i></i> Automated handoffs</span><span><i></i> Governed access</span></div>
        </div>
      </section>
    </main>
    <footer class="expertise-footer"><a href="/">RiverLabs</a><span>Built Around Your Business.</span><a href="/contact">Start a conversation <ArrowUpRight :size="12"/></a></footer>
  </div>
</template>

<style>
@import './expertise-showcase.css';
</style>
