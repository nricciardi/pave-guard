import { Module } from '@nestjs/common';
import { AuthenticationService } from './services/authentication/authentication.service';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { UserService } from './services/user/user.service';
import { MongooseModule } from '@nestjs/mongoose';
import { User, UserSchema } from './models/user.model';
import { AuthenticationResolver } from './resolvers/authentication.resolver';
import { UserResolver } from './resolvers/user.resolver';
import { JwtAuthenticationGuard } from './guards/jwt-authentication/jwt-authentication.guard';
import { AdminGuard } from './guards/admin/admin.guard';

@Module({
    providers: [
      // === SERVICEs ===
      UserService,
      AuthenticationService,

      // === RESOLVERs ===
      AuthenticationResolver,
      UserResolver,

      // === GUARDs ===
      JwtAuthenticationGuard,
      AdminGuard
    ],
    imports: [
        JwtModule.registerAsync({
            imports: [ConfigModule],
            useFactory: (configService: ConfigService) => ({
              secret: configService.get<string>('APP_KEY'),
              signOptions: { expiresIn: '1h' },
            }),
            inject: [ConfigService],
          }),
        MongooseModule.forFeature([
            {
                name: User.name,
                schema: UserSchema,
            },
        ])
    ],
    exports: [
      AuthenticationService,
      UserService,
      JwtModule,
      
      JwtAuthenticationGuard,
      AdminGuard,
    ]
})
export class UserModule {}
