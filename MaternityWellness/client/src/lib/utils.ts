import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

/**
 * Get initials from a name (first letter of first name and first letter of last name)
 * @param name The full name
 * @returns The initials (maximum 2 characters)
 */
export function getInitials(name: string): string {
  if (!name) return '';
  
  const names = name.split(' ').filter(Boolean);
  if (names.length === 0) return '';
  
  if (names.length === 1) {
    return names[0].charAt(0).toUpperCase();
  }
  
  return (names[0].charAt(0) + names[names.length - 1].charAt(0)).toUpperCase();
}
