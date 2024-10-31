import { CanActivate, createParamDecorator, ExecutionContext, Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GqlExecutionContext } from '@nestjs/graphql';
import { JwtService } from '@nestjs/jwt';
import { Observable } from 'rxjs';
import { JwtDto } from '../../dto/jwt.dto';
import { UserService } from '../../services/user/user.service';

export const Token = createParamDecorator(
  (data: unknown, context: ExecutionContext) => {

    const ctx = GqlExecutionContext.create(context);
    const request = ctx.getContext().req as Request;

    const token = extractTokenFromHeader(request);

    return token;
  },
);

@Injectable()
export class JwtAuthenticationGuard implements CanActivate {

  constructor(
    private readonly configService: ConfigService,
    private readonly jwtService: JwtService,
  ) {}

  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {

    return this.canPass(context)
  }

  canPass(context: ExecutionContext,): boolean {
    if(this.configService.get("DEBUG") === 'true')
      return true;

    try {
      return !!this.extractToken(context);      

    } catch(exception) {

      logger.log(`request blocked: ${exception}`);

      return false;
    }
  }

  extractRequest(context: ExecutionContext,): Request {

    const ctx = GqlExecutionContext.create(context);
    const request = ctx.getContext().req as Request;

    return request;
  }

  extractToken(context: ExecutionContext,): JwtDto {

    const request = this.extractRequest(context);

    const token = extractTokenFromHeader(request);

    return token;
  }
}

const logger = new Logger(JwtAuthenticationGuard.name);

function extractTokenFromHeader(request: Request): JwtDto {

  const APP_KEY = new ConfigService().get("APP_KEY");

  const authHeader = request.headers['authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer '))
    return null;
  
  const token = authHeader.split(' ')[1];  

  if (!token)
    throw new UnauthorizedException('token not found');

  try {
    
    const payload = new JwtService().verify(token, { secret: APP_KEY });

    return payload;

  } catch (error) {

    throw new UnauthorizedException('invalid or expired token');
  }
}
