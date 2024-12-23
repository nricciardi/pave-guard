import { Module } from '@nestjs/common';
import { ModelService } from './services/model/model.service';
import { UtilitiesService } from './services/utilities/utilities.service';
import { DeviceModule } from '../device/device.module';
import { TelemetryModule } from '../telemetry/telemetry.module';

@Module({
  providers: [
    ModelService,
    UtilitiesService
  ],
  imports: [
    DeviceModule,
    TelemetryModule
  ]
})
export class ModelModule {}
