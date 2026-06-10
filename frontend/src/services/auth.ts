import { api } from './api'
import { clearAuthToken, getAuthToken, setAuthToken } from './session'
import type { AuthResponse, LoginPayload, RegisterPayload, User } from '../types'

export function getStoredAuthToken(): string | null {
  return getAuthToken()
}

export function clearStoredAuthToken(): void {
  clearAuthToken()
}

export async function login(payload: LoginPayload): Promise<AuthResponse> {
  const response = await api.post<AuthResponse>('/api/auth/login', payload)
  setAuthToken(response.data.access_token)
  return response.data
}

export async function register(payload: RegisterPayload): Promise<AuthResponse> {
  const response = await api.post<AuthResponse>('/api/auth/register', payload)
  setAuthToken(response.data.access_token)
  return response.data
}

export async function fetchMe(): Promise<User> {
  const response = await api.get<User>('/api/auth/me')
  return response.data
}