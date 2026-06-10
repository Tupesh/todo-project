import { api } from './api'
import type { Todo, TodoCreate, TodoUpdate } from '../types'

export async function fetchTodos(): Promise<Todo[]> {
  const response = await api.get<Todo[]>('/api/todos')
  return response.data
}

export async function createTodo(payload: TodoCreate): Promise<Todo> {
  const response = await api.post<Todo>('/api/todos', payload)
  return response.data
}

export async function updateTodo(id: number, payload: TodoUpdate): Promise<Todo> {
  const response = await api.patch<Todo>(`/api/todos/${id}`, payload)
  return response.data
}

export async function deleteTodo(id: number): Promise<void> {
  await api.delete(`/api/todos/${id}`)
}
