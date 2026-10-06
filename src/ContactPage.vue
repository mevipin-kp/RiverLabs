<script setup>
import { onMounted, ref } from 'vue'
import { ArrowLeft, ArrowRight, Check, Workflow } from '@lucide/vue'

const selectedInterest = ref('')
const submitted = ref(false)
const contactName = ref('')

onMounted(() => {
  document.title = 'Contact RiverLabs'
  const product = new URLSearchParams(window.location.search).get('product')
  if (!product) return
  const normalized = product.trim().toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ')
  const options = ['RiverFlow', 'River Auto', 'River Hire', 'River Build', 'River Retail', 'River Fleet', 'AI Automation', 'Odoo Implementation', 'ERP Solutions']
  selectedInterest.value = options.find(option => option.toLowerCase().replaceAll(' ', '') === normalized.replaceAll(' ', '')) || ''
})

function submitEnquiry(event) {
  if (!event.currentTarget.reportValidity()) return
  submitted.value = true
}
</script>

<template>
  <div class="contact-page">
    <header class="contact-page-header">
      <a href="/" class="contact-brand" aria-label="RiverLabs home"><span class="contact-brand-mark"><i></i><i></i><i></i><i></i><i></i></span>RiverLabs</a>
      <a href="/" class="contact-back"><ArrowLeft :size="14"/> Back to RiverLabs</a>
    </header>

    <main class="contact-page-main">
      <section class="contact-page-intro">
        <div class="contact-page-kicker"><Workflow :size="14"/> START A CONVERSATION</div>
        <h1>Tell us where<br/>the work gets<br/><em>stuck.</em></h1>
        <p>Share a little about your business and what you’re looking to improve. We’ll use it to make the first conversation useful.</p>
        <div class="contact-page-note"><span><Check :size="13"/></span><div><strong>Built around your business</strong><small>Start with the process. We’ll work out the right solution together.</small></div></div>
        <div class="contact-page-index"><span>RIVERLABS</span><i></i><span>CONTACT</span></div>
      </section>

      <section class="contact-form-panel" aria-labelledby="contact-form-title">
        <div class="contact-form-heading"><span>YOUR DETAILS</span><h2 id="contact-form-title">Let’s begin.</h2><p>Fields marked <b>*</b> are required.</p></div>
        <form v-if="!submitted" class="river-contact-form" @submit.prevent="submitEnquiry">
          <div class="contact-fields-grid">
            <label class="contact-field"><span>Full name <b>*</b></span><input v-model="contactName" name="name" autocomplete="name" placeholder="Your name" required/></label>
            <label class="contact-field"><span>Work email <b>*</b></span><input type="email" name="email" autocomplete="email" placeholder="you@company.com" required/></label>
            <label class="contact-field"><span>Company <b>*</b></span><input name="company" autocomplete="organization" placeholder="Company name" required/></label>
            <label class="contact-field"><span>Phone <small>OPTIONAL</small></span><input type="tel" name="phone" autocomplete="tel" placeholder="+971 50 000 0000"/></label>
            <label class="contact-field contact-field-wide"><span>What would you like to discuss? <b>*</b></span><span class="contact-select-wrap"><select v-model="selectedInterest" name="interest" required><option value="" disabled>Select a product or service</option><optgroup label="Products"><option>RiverFlow</option><option>River Auto</option><option>River Hire</option><option>River Build</option><option>River Retail</option><option>River Fleet</option></optgroup><optgroup label="Services"><option>AI Automation</option><option>Odoo Implementation</option><option>ERP Solutions</option></optgroup></select><span class="contact-select-chevron">⌄</span></span></label>
            <label class="contact-field contact-field-wide"><span>Anything else we should know? <small>OPTIONAL</small></span><textarea name="message" rows="3" placeholder="A brief note about the process, challenge, or outcome you have in mind."></textarea></label>
          </div>
          <div class="contact-form-actions"><p>This preview keeps the form in your browser. It won’t send your details.</p><button type="submit">Submit enquiry <ArrowRight :size="15"/></button></div>
        </form>
        <div v-else class="contact-form-success" role="status" aria-live="polite"><span><Check :size="18"/></span><div><small>ENQUIRY PREVIEW READY</small><h3>Thanks, {{ contactName }}.</h3><p>This form is a front-end preview and hasn’t sent your details. Connect a submission service to receive enquiries.</p><a href="/">Return to RiverLabs</a></div></div>
      </section>
    </main>
    <footer class="contact-page-footer"><span>© {{ new Date().getFullYear() }} RiverLabs</span><span>BUILT AROUND YOUR BUSINESS</span><a href="/">riverlabs</a></footer>
  </div>
</template>

<style>
@import './contact-page.css';
</style>
