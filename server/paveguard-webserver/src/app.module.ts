import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TelemetryControllerController } from './controllers/telemetry-controller/telemetry-controller.controller';

@Module({
  imports: [],
  controllers: [AppController, TelemetryControllerController],
  providers: [AppService],
})
export class AppModule {}
