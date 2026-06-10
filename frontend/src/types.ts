export interface Todo {
  id: number
  title: string
  completed: boolean
  created_at: string
}

export interface TodoCreate {
  title: string
}

export interface TodoUpdate {
  title?: string
  completed?: boolean
}

export interface User {
  id: number
  email: string
  created_at: string
}

export interface LoginPayload {
  email: string
  password: string
}

export interface RegisterPayload extends LoginPayload {
  confirmPassword?: string
}

export interface AuthResponse {
  access_token: string
  token_type: 'bearer'
  user: User
}
