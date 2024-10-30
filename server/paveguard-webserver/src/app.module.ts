import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';
import configuration from 'config/configuration';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { TelemetryModule } from './modules/telemetry/telemetry.module';
import { UserModule } from './modules/user/authentication.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      envFilePath: ['.env'],
      load: [configuration],
      isGlobal: true
    }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => {

        let uri = `mongodb://${configService.get('DB_USER')}:${configService.get('DB_PASS')}@${configService.get('DB_HOST')}:${configService.get('DB_PORT')}/${configService.get('DB_NAME')}`;

        // DEBUG: console.log(`connect to ${uri}`);
        
        return ({
          uri,
        })
      },
    }),
    GraphQLModule.forRootAsync<ApolloDriverConfig>({
      imports: [ConfigModule],
      inject: [ConfigService],
      driver: ApolloDriver,
      useFactory: async (configService: ConfigService) => ({
        autoSchemaFile: true,
        playground: configService.get('GRAPHQL_PLAYGROUND_ENABLED') === 'true',
        path: configService.get('GRAPHQL_PATH'),
        include: [
          TelemetryModule,
          UserModule,
        ]
      }),
    }),
    TelemetryModule,
    UserModule,
  ],
  controllers: [
    AppController,
  ],
  providers: [
    AppService,
  ],
})
export class AppModule {}
