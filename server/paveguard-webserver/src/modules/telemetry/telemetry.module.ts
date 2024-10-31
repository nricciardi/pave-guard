import { Module } from '@nestjs/common';
import { TelemetryService } from './services/telemetry/telemetry.service';
import { TemperatureTelemetryService } from './services/temperature-telemetry/temperature-telemetry.service';
import { TemperatureTelemetry, TemperatureTelemetrySchema } from './models/temperature-telemetry.model';
import { MongooseModule } from '@nestjs/mongoose';
import { Telemetry, TelemetrySchema } from './models/telemetry.model';
import { TelemetryResolver } from './resolvers/telemetry.resolver';
import { TemperatureTelemetryResolver } from './resolvers/temperature-telemetry.resolver';
import { HumidityTelemetryService } from './services/humidity-telemetry/humidity-telemetry.service';
import { HumidityTelemetry, HumidityTelemetrySchema } from './models/humidity-telemetry.model';
import { HumidityTelemetryResolver } from './resolvers/humidity-telemetry.resolver';
import { UserModule } from '../user/user.module';
import { UserService } from '../user/services/user/user.service';
import { TrafficTelemetry, TrafficTelemetrySchema } from './models/traffic-telemetry.model';
import { TrafficTelemetryService } from './services/traffic-telemetry/traffic-telemetry.service';
import { TrafficTelemetryResolver } from './resolvers/traffic-telemetry.resolver';

@Module({
    controllers: [
    ],
    providers: [
        // === SERVICEs ===
        TelemetryService,
        TemperatureTelemetryService,
        HumidityTelemetryService,
        TrafficTelemetryService,

        // === RESOLVERs ===
        TelemetryResolver,
        TemperatureTelemetryResolver,
        HumidityTelemetryResolver,
        TrafficTelemetryResolver,
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
                    },
                    {
                        name: HumidityTelemetry.name,
                        schema: HumidityTelemetrySchema
                    },
                    {
                        name: TrafficTelemetry.name,
                        schema: TrafficTelemetrySchema
                    }
                ]
            },
        ]),
        UserModule,
    ],
    exports: [
    ],
})
export class TelemetryModule {}
