import { CanActivate, createParamDecorator, ExecutionContext, Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GqlExecutionContext } from '@nestjs/graphql';
import { JwtService } from '@nestjs/jwt';
import { Observable } from 'rxjs';
import { JwtDto } from '../../dto/jwt.dto';
import { UserService } from '../../services/user/user.service';
import { JwtAuthenticationGuard } from '../jwt-authentication/jwt-authentication.guard';


@Injectable()
export class AdminGuard implements CanActivate {

    private readonly logger = new Logger(AdminGuard.name);

    constructor(
        private readonly jwtGuard: JwtAuthenticationGuard,
        private readonly userService: UserService,
    ) {}

    canActivate(
        context: ExecutionContext,
      ): boolean | Promise<boolean> | Observable<boolean> {
    
        return new Promise(async (resolve, reject) => {

            try {
                const superResult = this.jwtGuard.canPass(context);

                if(!superResult)
                    resolve(false);

                const token = this.jwtGuard.extractToken(context);

                resolve((await this.userService.findById(token.userId)).admin);
            
            } catch (error) {
                reject(error);
            }
        });
    }
}