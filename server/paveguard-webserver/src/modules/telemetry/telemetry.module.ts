import { Module } from '@nestjs/common';
import { TelemetryService } from './service/telemetry-service.service';
import { TemperatureTelemetryService } from './temperature-telemetry/service/temperature-telemetry-service.service';
import { TelemetryController } from './controller/telemetry-controller.controller';
import { TemperatureTelemetry, TemperatureTelemetrySchema } from './temperature-telemetry/models/temperature-telemetry-schema.model';
import { MongooseModule } from '@nestjs/mongoose';
import { Telemetry, TelemetrySchema } from './model/telemetry-schema.model';

@Module({
    controllers: [
        TelemetryController
    ],
    providers: [
        TelemetryService,
        TemperatureTelemetryService
    ],
    imports: [
        MongooseModule.forFeature([
            {
                name: Telemetry.name,
                schema: TelemetrySchema,
                discriminators: [
                    {
                        name: TemperatureTelemetry.name,
                        schema: TemperatureTelemetrySchema
                    }
                ]
            },
        ])
    ],
    exports: [
        TelemetryService,
        TemperatureTelemetryService
    ],
})
export class TelemetryModule {}
