<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { ArrowRight, ArrowUpRight, Blocks, ChevronDown, Menu, Network, Workflow, X } from '@lucide/vue'

defineProps({ mode: { type: String, default: 'home' } })

const menuOpen = ref(false)
const productsMenuOpen = ref(false)
const mobileOpen = ref(false)
const scrolled = ref(false)
const solutionsButton = ref(null)
const productsButton = ref(null)
const mobileButton = ref(null)
const products = [
  { name: 'River Auto', description: 'Automotive Management', href: '/products/river-auto' },
  { name: 'River Hire', description: 'Recruitment & HR Consultancy', href: '/products/river-hire' },
  { name: 'River Build', description: 'Building & Facility Management', href: '/products/river-build' },
  { name: 'River Retail', description: 'Retail & Commerce Management', href: '/products/river-retail' },
  { name: 'River Fleet', description: 'Fleet & Vehicle Management', href: '/products/river-fleet' },
  { name: 'River Flow', description: 'Workflow & Process Automation', href: '/products/river-flow' },
]
const serviceGroups = [
  { name: 'AI Automation', label: 'Smarter everyday operations', description: 'Automate repetitive work with AI.', icon: Workflow, href: '/expertise#ai-automation', tone: 'lilac' },
  { name: 'Odoo Implementation', label: 'Systems fitted to your business', description: 'Configure Odoo around your processes.', icon: Blocks, href: '/expertise#odoo-implementation', tone: 'lime' },
  { name: 'ERP Solutions', label: 'Connected business systems', description: 'Make your systems work together.', icon: Network, href: '/expertise#erp-solutions', tone: 'blue' },
]

function onScroll() { scrolled.value = window.scrollY > 24 }
function closeMenus() { menuOpen.value = false; productsMenuOpen.value = false; mobileOpen.value = false }
function onDocumentPointerDown(event) {
  if (event.target.closest?.('.nav-menu-group, .mobile-menu-button, .mobile-nav')) return
  closeMenus()
}
function onDocumentKeydown(event) {
  if (event.key !== 'Escape') return
  const focusTarget = mobileOpen.value ? mobileButton.value : productsMenuOpen.value ? productsButton.value : solutionsButton.value
  const hadOpenMenu = menuOpen.value || productsMenuOpen.value || mobileOpen.value
  closeMenus()
  if (hadOpenMenu) focusTarget?.focus()
}
onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  document.addEventListener('pointerdown', onDocumentPointerDown)
  document.addEventListener('keydown', onDocumentKeydown)
  onScroll()
})
onUnmounted(() => {
  window.removeEventListener('scroll', onScroll)
  document.removeEventListener('pointerdown', onDocumentPointerDown)
  document.removeEventListener('keydown', onDocumentKeydown)
})
</script>

<template>
  <header class="site-header" :class="[{ compact: mode === 'home' && scrolled }, { subpage: mode === 'subpage' }]">
    <a class="wordmark" href="/#top" aria-label="RiverLabs home" @click="closeMenus"><span class="sound-mark"><i></i><i></i><i></i><i></i><i></i></span><span>RiverLabs</span></a>
    <nav class="desktop-nav" aria-label="Main navigation">
      <div class="nav-menu-group">
        <button ref="solutionsButton" id="solutions-menu-button" class="nav-trigger" :class="{ selected: menuOpen }" aria-controls="solutions-menu" :aria-expanded="menuOpen" @click="menuOpen = !menuOpen; productsMenuOpen = false">Solutions <ChevronDown :size="15" /></button>
        <Transition name="mega"><div v-show="menuOpen" id="solutions-menu" class="mega-menu" role="group" aria-labelledby="solutions-menu-button"><div class="mega-topline"><span>RIVERLABS EXPERTISE</span><span>Diagnose first. Automate next.</span></div><a v-for="service in serviceGroups" :key="service.name" :href="service.href" class="mega-product" @click="closeMenus"><span class="mega-icon" :class="service.tone"><component :is="service.icon" :size="20" /></span><span class="mega-copy"><strong>{{ service.name }} <ArrowUpRight :size="13" /></strong><small>{{ service.description }}</small></span><span class="mega-label">{{ service.label }}</span></a><div class="mega-footer"><span>Built around your processes</span><a href="/expertise" @click="closeMenus">Our expertise <ArrowRight :size="14" /></a></div></div></Transition>
      </div>
      <div class="nav-menu-group">
        <button ref="productsButton" id="products-menu-button" class="nav-trigger" :class="{ selected: productsMenuOpen }" aria-controls="products-menu" :aria-expanded="productsMenuOpen" @click="productsMenuOpen = !productsMenuOpen; menuOpen = false">Products <ChevronDown :size="15" /></button>
        <Transition name="mega"><div v-show="productsMenuOpen" id="products-menu" class="products-mega-menu" role="group" aria-labelledby="products-menu-button"><div class="mega-topline"><span>RIVERLABS PRODUCTS</span><span>Purpose-built business solutions</span></div><div class="products-mega-grid"><a v-for="product in products" :key="product.name" :href="product.href" class="product-mega-link" @click="closeMenus"><strong>{{ product.name }} <ArrowUpRight :size="13" /></strong><small>{{ product.description }}</small></a></div></div></Transition>
      </div>
      <a href="/expertise">Our Expertise</a>
      <a href="/#site-footer">About</a>
      <a href="/contact">Contact</a>
    </nav>
    <div class="header-right"><a class="sign-in" href="/expertise">What we do <ArrowUpRight :size="15" /></a><a class="header-cta" href="/contact">Get in touch <ArrowRight :size="16" /></a></div>
    <button ref="mobileButton" class="mobile-menu-button" :aria-label="mobileOpen ? 'Close navigation menu' : 'Open navigation menu'" aria-controls="mobile-navigation" :aria-expanded="mobileOpen" @click="mobileOpen = !mobileOpen"><X v-if="mobileOpen" :size="22"/><Menu v-else :size="22"/></button>
  </header>
  <Transition name="mobile"><nav v-show="mobileOpen" id="mobile-navigation" class="mobile-nav" aria-label="Mobile navigation"><div class="mobile-nav-label">SOLUTIONS</div><a v-for="service in serviceGroups" :key="service.name" :href="service.href" @click="closeMenus"><component :is="service.icon" :size="19"/> {{ service.name }} <ArrowRight :size="16"/></a><div class="mobile-nav-label">PRODUCTS</div><a v-for="product in products" :key="product.name" :href="product.href" @click="closeMenus">{{ product.name }} <span class="mobile-product-description">— {{ product.description }}</span><ArrowRight :size="16"/></a><div class="mobile-nav-label">RIVERLABS</div><a href="/expertise" @click="closeMenus">Our Expertise <ArrowRight :size="16"/></a><a href="/#site-footer" @click="closeMenus">About <ArrowRight :size="16"/></a><a class="mobile-nav-cta" href="/contact" @click="closeMenus">Get in touch <ArrowRight :size="16"/></a></nav></Transition>
</template>
