import { MiddlewareConsumer, Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';
import configuration from 'config/configuration';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { TelemetryModule } from './modules/telemetry/telemetry.module';
import { UserModule } from './modules/user/user.module';
import { LoggerMiddleware } from './middlewares/logger/logger.middleware';
import { DeviceModule } from './modules/device/device.module';
import { ModelModule } from './modules/model/model.module';
import { ManagementModule } from './modules/management/management.module';

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

        let port = "";
        if(!!configService.get('DB_PORT')) {
          port = `:${configService.get('DB_PORT')}`;
        }

        let params = "";
        if(!!configService.get('DB_PARAMS')) {
          params = `?${configService.get('DB_PARAMS')}`;
        }

        const uri = `${configService.get('DB_PROT')}://${configService.get('DB_USER')}:${configService.get('DB_PASS')}@${configService.get('DB_HOST')}${port}/${configService.get('DB_NAME')}${params}`;

        console.log(`connect to ${uri}`);
        
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
          DeviceModule,
          ModelModule,
          ManagementModule,
        ]
      }),
    }),
    TelemetryModule,
    UserModule,
    DeviceModule,
    ModelModule,
    ManagementModule,
  ],
  controllers: [
    AppController,
  ],
  providers: [
    AppService,
  ],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(LoggerMiddleware)
      .forRoutes('graphql');
  }
}
