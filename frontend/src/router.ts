import { createRouter, createWebHistory } from 'vue-router'

import { getStoredAuthToken } from './services/auth'
import DashboardView from './views/DashboardView.vue'
import LandingView from './views/LandingView.vue'
import SignInView from './views/SignInView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', name: 'landing', component: LandingView },
    { path: '/signin', name: 'signin', component: SignInView },
    { path: '/dashboard', name: 'dashboard', component: DashboardView },
  ],
})

router.beforeEach((to) => {
  const hasToken = Boolean(getStoredAuthToken())

  if (to.path === '/dashboard' && !hasToken) {
    return { path: '/signin' }
  }

  if (to.path === '/signin' && hasToken) {
    return { path: '/dashboard' }
  }

  return true
})

export { router }
