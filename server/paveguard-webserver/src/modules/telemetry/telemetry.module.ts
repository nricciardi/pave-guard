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
import { TrafficTelemetry, TrafficTelemetrySchema } from './models/traffic-telemetry.model';
import { TrafficTelemetryService } from './services/traffic-telemetry/traffic-telemetry.service';
import { TrafficTelemetryResolver } from './resolvers/traffic-telemetry.resolver';
import { RoadCrackService } from './services/road-crack/road-crack.service';
import { RoadPotholeService } from './services/road-pothole/road-pothole.service';
import { RoadCrackTelemetryResolver } from './resolvers/road-crack-telemetry.resolver';
import { RoadPotholeTelemetryResolver } from './resolvers/road-pothole-telemetry.resolver';
import { RoadCrackTelemetry, RoadCrackTelemetrySchema } from './models/road-crack-telemetry.model';
import { RoadPotholeTelemetry, RoadPotholeTelemetrySchema } from './models/road-pothole-telemetry.model';
import { FailTelemetry, FailTelemetrySchema } from './models/fail-telemetry.model';
import { FailTelemetryService } from './services/fail-telemetry/fail-telemetry.service';
import { FailTelemetryResolver } from './resolvers/fail-telemetry.resolver';
import { RainTelemetry, RainTelemetrySchema } from './models/rain-telemetry.model';
import { RainTelemetryService } from './services/rain-telemetry/rain-telemetry.service';
import { RainTelemetryResolver } from './resolvers/rain-telemetry.resolver';

@Module({
    controllers: [
    ],
    providers: [
        // === SERVICEs ===
        TelemetryService,
        TemperatureTelemetryService,
        HumidityTelemetryService,
        TrafficTelemetryService,
        RoadCrackService,
        RoadPotholeService,
        FailTelemetryService,
        RainTelemetryService,

        // === RESOLVERs ===
        TelemetryResolver,
        TemperatureTelemetryResolver,
        HumidityTelemetryResolver,
        TrafficTelemetryResolver,
        RoadCrackTelemetryResolver,
        RoadPotholeTelemetryResolver,
        FailTelemetryResolver,
        RainTelemetryResolver,
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
                    },
                    {
                        name: RoadCrackTelemetry.name,
                        schema: RoadCrackTelemetrySchema
                    },
                    {
                        name: RoadPotholeTelemetry.name,
                        schema: RoadPotholeTelemetrySchema
                    },
                    {
                        name: FailTelemetry.name,
                        schema: FailTelemetrySchema
                    },
                    {
                        name: RainTelemetry.name,
                        schema: RainTelemetrySchema
                    },
                ]
            },
        ]),
        UserModule,
    ],
    exports: [
    ],
})
export class TelemetryModule {}
