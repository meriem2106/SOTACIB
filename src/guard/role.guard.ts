import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

@Injectable()
export class RoleGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {} // Use Reflector to get metadata

  canActivate(context: ExecutionContext): boolean {
    const requiredRole = this.reflector.get<string>('role', context.getHandler()); // Get the role from metadata
    if (!requiredRole) {
      return true; // No role required, allow access
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || user.role !== requiredRole) {
      throw new UnauthorizedException('You do not have permission to access this resource.');
    }

    return true; // Allow access if roles match
  }
}