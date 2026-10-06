<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { ArrowRight, ArrowUpRight, AudioLines, Check, Play, ShieldCheck, Sparkles } from '@lucide/vue'
import ProductShowcase from './ProductShowcase.vue'
import RiverFlowShowcase from './RiverFlowShowcase.vue'
import ContactPage from './ContactPage.vue'
import ExpertiseShowcase from './ExpertiseShowcase.vue'
import SiteHeader from './SiteHeader.vue'

const activeHeroIndex = ref(0)
const heroRotationPaused = ref(false)
const heroHovered = ref(false)
const heroFocusWithin = ref(false)
let heroRotationTimer
const year = new Date().getFullYear()
const heroMessages = [
  {
    heading: 'Discover the need. Engineer the answer. Make it yours.',
    lines: ['Discover the need.', 'Engineer the', 'answer.', 'Make it yours.'],
    description: 'We identify where businesses are held back by friction, complexity, and manual work, then create fit-for-purpose technology that connects naturally with the way they operate and remains firmly in their hands.',
  },
  {
    heading: 'Diagnose first. Automate next. Build capability that lasts.',
    lines: ['Diagnose first.', 'Automate next.', 'Build capability', 'that lasts.'],
    description: 'We help established businesses uncover where time, effort, and value are being lost. Then we design and automate what the diagnosis calls for—around your processes, within your infrastructure, and with your team in control.',
  },
  {
    heading: 'From complexity. To clarity. To foresight.',
    lines: ['From complexity.', 'To clarity.', 'To foresight.'],
    description: 'We uncover what’s slowing your business down, connect the processes and data that matter, and build technology around the way you actually work. Beyond automation, we turn your data into actionable intelligence—helping you anticipate change, forecast outcomes, and make better-informed decisions about what comes next.',
  },
]
const activeHeroMessage = computed(() => heroMessages[activeHeroIndex.value])
const isContactPage = computed(() => window.location.pathname === '/contact')
const isExpertisePage = computed(() => window.location.pathname === '/expertise')
const products = [
  { name: 'River Auto', description: 'Automotive Management', href: '/products/river-auto' },
  { name: 'River Hire', description: 'Recruitment & HR Consultancy', href: '/products/river-hire' },
  { name: 'River Build', description: 'Building & Facility Management', href: '/products/river-build' },
  { name: 'River Retail', description: 'Retail & Commerce Management', href: '/products/river-retail' },
  { name: 'River Fleet', description: 'Fleet & Vehicle Management', href: '/products/river-fleet' },
  { name: 'River Flow', description: 'Workflow & Process Automation', href: '/products/river-flow' },
]
const currentProduct = computed(() => products.find(product => product.href === window.location.pathname))

function selectHeroMessage(index) { activeHeroIndex.value = index }
function onHeroFocusOut(event) {
  if (!event.currentTarget.contains(event.relatedTarget)) heroFocusWithin.value = false
}
function scheduleHeroRotation() {
  const delay = Math.max(10000, Math.min(22000, activeHeroMessage.value.description.length * 60))
  heroRotationTimer = window.setTimeout(() => {
    if (!heroRotationPaused.value && !heroHovered.value && !heroFocusWithin.value && document.visibilityState === 'visible') {
      activeHeroIndex.value = (activeHeroIndex.value + 1) % heroMessages.length
    }
    scheduleHeroRotation()
  }, delay)
}
onMounted(() => {
  if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    scheduleHeroRotation()
  }
})
onUnmounted(() => {
  window.clearTimeout(heroRotationTimer)
})
</script>

<template>
  <ContactPage v-if="isContactPage" />
  <ExpertiseShowcase v-else-if="isExpertisePage" />
  <RiverFlowShowcase v-else-if="currentProduct?.href === '/products/river-flow'" />
  <ProductShowcase v-else-if="currentProduct" :product="currentProduct" />
  <div v-else class="site-shell">
    <SiteHeader />

    <main id="top">
      <section class="hero-section">
        <div class="hero-wash"></div>
        <div class="hero-inner">
          <div class="hero-copy" @mouseenter="heroHovered = true" @mouseleave="heroHovered = false" @focusin="heroFocusWithin = true" @focusout="onHeroFocusOut">
            <div class="hero-kicker"><span class="kicker-line"></span>PROCESS DIAGNOSIS &amp; AUTOMATION<span class="kicker-index">01 / 04</span></div>
            <Transition name="hero-message" mode="out-in"><div :key="activeHeroIndex" class="hero-message" role="group" aria-roledescription="slide" :aria-label="`Message ${activeHeroIndex + 1} of ${heroMessages.length}`"><h1 :aria-label="activeHeroMessage.heading"><span v-for="(line, index) in activeHeroMessage.lines" :key="line" :class="{ 'last-line': index === activeHeroMessage.lines.length - 1 }">{{ line.endsWith('.') ? line.slice(0, -1) : line }}<span v-if="line.endsWith('.')" class="period">.</span></span></h1><p class="hero-desc">{{ activeHeroMessage.description }}</p></div></Transition>
            <div class="hero-message-controls" role="group" aria-label="Choose an introduction message"><button v-for="(message, index) in heroMessages" :key="message.heading" class="hero-message-dot" :class="{ active: activeHeroIndex === index }" :aria-label="`Show message ${index + 1}: ${message.heading}`" :aria-pressed="activeHeroIndex === index" @click="selectHeroMessage(index)"><span></span></button><button class="hero-rotation-toggle" :aria-label="heroRotationPaused ? 'Resume message rotation' : 'Pause message rotation'" @click="heroRotationPaused = !heroRotationPaused"><Play v-if="heroRotationPaused" :size="13" fill="currentColor"/><span v-else class="pause-icon"><i></i><i></i></span></button></div>
            <div id="expertise" class="hero-expertise"><span>Our Expertise</span><div class="expertise-items"><span class="expertise-item">AI Automation</span><i>·</i><span class="expertise-item">Odoo Implementation</span><i>·</i><span class="expertise-item">ERP Solutions</span></div></div>
            <div class="hero-actions"><a href="/expertise" class="button-dark">Explore our expertise <ArrowRight :size="16" /></a><a class="text-cta" href="/contact">Talk to our team <ArrowUpRight :size="15" /></a></div>
            <div class="hero-proof"><span class="proof-check"><Check :size="12" /></span><span>Designed around your processes</span><span class="proof-separator"></span><span>Your team stays in control</span></div>
          </div>
          <div class="hero-art" aria-label="RiverLabs automation workspace preview">
            <div class="art-orbit orbit-large"></div><div class="art-orbit orbit-small"></div>
            <div class="art-tag tag-secure"><ShieldCheck :size="14"/> Secure by design</div>
            <div class="product-window">
              <div class="window-top"><div class="window-brand"><span class="mini-sound"><i></i><i></i><i></i></span>RiverFlow</div><div class="window-search">⌕ <span>Search workflows</span><kbd>⌘ K</kbd></div><div class="window-user">JD</div></div>
              <div class="window-body"><aside class="window-sidebar"><div class="window-side-label">WORKSPACE</div><div class="side-link selected"><span>▦</span> Overview</div><div class="side-link"><span>◷</span> Automations</div><div class="side-link"><span>⌕</span> Search</div><div class="window-side-label side-label-spaced">OPERATIONS</div><div class="side-link"><span>◇</span> Integrations</div><div class="side-link"><span>▤</span> Reports</div><div class="side-link"><span>⚙</span> Settings</div><div class="window-sidebar-foot"><span class="online-mark"></span> All systems operational</div></aside>
                <div class="window-main"><div class="window-greeting">MONDAY, 05 OCTOBER 2026</div><div class="window-title">Good morning, Jordan</div><div class="window-subtitle">Here’s the latest across your workflows.</div><div class="mini-stat-row"><div class="mini-stat"><small>WORKFLOWS RUN</small><strong>1,284</strong><em>↗ 12.8%</em></div><div class="mini-stat"><small>HOURS RETURNED</small><strong>8,492</strong><em>↗ 8.2%</em></div><div class="mini-stat"><small>AUTOMATED</small><strong>94.6%</strong><em>↗ 2.4%</em></div></div><div class="window-chart-card"><div class="window-card-head"><span>Automation activity</span><small>Last 7 days⌄</small></div><div class="chart-bars"><i style="--h:35%"></i><i style="--h:54%"></i><i style="--h:43%"></i><i style="--h:72%"></i><i style="--h:59%"></i><i style="--h:88%"></i><i style="--h:68%"></i><i style="--h:100%"></i><i style="--h:77%"></i><i style="--h:91%"></i><i style="--h:70%"></i><i style="--h:84%"></i><i style="--h:62%"></i><i style="--h:94%"></i><i style="--h:74%"></i><i style="--h:100%"></i></div><div class="chart-days"><span>MON</span><span>TUE</span><span>WED</span><span>THU</span><span>FRI</span><span>SAT</span><span>SUN</span></div></div><div class="window-card-head recordings-heading"><span>Recent workflow runs</span><small>View all →</small></div><div class="recording-row"><span class="recording-avatar av-lime">NH</span><span class="recording-name">Invoice processing<small>Finance · completed</small></span><span class="recording-wave"><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i></span><span class="recording-pill">Complete</span></div><div class="recording-row"><span class="recording-avatar av-purple">MC</span><span class="recording-name">Order fulfilment<small>Operations · completed</small></span><span class="recording-wave wave-purple"><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i></span><span class="recording-pill">Complete</span></div></div></div>
              <div class="window-bottom"><span><i></i> ERP integration active</span><span>Updated just now</span></div>
            </div>
            <div class="floating-note insight-note"><span class="note-icon"><Sparkles :size="15" /></span><span><small>AI INSIGHT</small><strong>Manual work reduced by <b>42%</b></strong></span><ArrowUpRight :size="14"/></div>
            <div class="floating-note audio-note"><span class="audio-play"><Play :size="12" fill="currentColor"/></span><span class="audio-content"><strong>Workflow completed</strong><small>00:42 <span class="audio-wave"><i v-for="n in 18" :key="n" :style="{height: `${5 + (n * 7 % 13)}px`} "></i></span> 04:18</small></span><span class="audio-live">LIVE</span></div>
            <div class="hero-vertical">LISTEN CLOSER <span></span> SEE FURTHER</div>
          </div>
        </div>
        <a href="#site-footer" class="scroll-cue"><span>SCROLL TO EXPLORE</span><span class="scroll-mouse"><i></i></span></a>
        <div class="hero-counter"><span>01</span><i></i><span>04</span></div>
      </section>

    </main>

    <footer id="site-footer" class="site-footer"><div class="footer-main"><div class="footer-brand-col"><a class="wordmark footer-wordmark" href="#top"><span class="sound-mark"><i></i><i></i><i></i><i></i><i></i></span><span>RiverLabs</span></a><p>Built Around Your<br/>Business.</p></div><div class="footer-column"><span>EXPERTISE</span><a href="/expertise#ai-automation">AI Automation <ArrowUpRight :size="12"/></a><a href="/expertise#odoo-implementation">Odoo Implementation <ArrowUpRight :size="12"/></a><a href="/expertise#erp-solutions">ERP Solutions <ArrowUpRight :size="12"/></a></div><div class="footer-column"><span>OUR APPROACH</span><a href="#top">Process diagnosis <ArrowUpRight :size="12"/></a><a href="/expertise#ai-automation">Automation design <ArrowUpRight :size="12"/></a><a href="/expertise#odoo-implementation">Team enablement <ArrowUpRight :size="12"/></a></div><div class="footer-column"><span>GET IN TOUCH</span><a href="/contact">Start a conversation <ArrowUpRight :size="12"/></a><a href="/expertise">Explore our services <ArrowUpRight :size="12"/></a></div><div class="footer-newsletter"><span>THE OCCASIONAL GOOD THING</span><p>Practical ideas for better business systems and automation.</p><form @submit.prevent="($event.target.reset(), $event.target.classList.add('submitted'))"><input type="email" placeholder="Your email address" required/><button type="submit" aria-label="Subscribe"><ArrowRight :size="16"/></button><small>Thanks — you're on the list.</small></form></div></div><div class="footer-bottom"><span>© {{ year }} RiverLabs. All rights reserved.</span><div><a href="#">Terms</a><a href="#">Privacy</a><a href="#">Cookies</a></div><span class="footer-location">MADE TO HEAR MORE <AudioLines :size="14"/></span></div></footer>

  </div>
</template>
