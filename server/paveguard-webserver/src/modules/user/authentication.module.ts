import { Module } from '@nestjs/common';
import { AuthenticationService } from './services/authentication/authentication.service';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
    imports: [
        JwtModule.registerAsync({
            imports: [ConfigModule],
            useFactory: (configService: ConfigService) => ({
              secret: configService.get<string>('APP_KEY'),
              signOptions: { expiresIn: '1h' },
            }),
            inject: [ConfigService],
          }),
    ],
    exports: [AuthenticationService, JwtModule]
})
export class AuthenticationModule {}
