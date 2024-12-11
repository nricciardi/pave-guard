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
import { TransitTelemetry, TransitTelemetrySchema } from './models/transit-telemetry.model';
import { TrafficTelemetryService } from './services/transit-telemetry/transit-telemetry.service';
import { TransitTelemetryResolver } from './resolvers/transit-telemetry.resolver';
import { RoadCrackService } from './services/road-crack/road-crack.service';
import { RoadPotholeService } from './services/road-pothole/road-pothole.service';
import { RoadCrackTelemetryResolver } from './resolvers/road-crack-telemetry.resolver';
import { RoadPotholeTelemetryResolver } from './resolvers/road-pothole-telemetry.resolver';
import { RoadCrackTelemetry, RoadCrackTelemetrySchema } from './models/road-crack-telemetry.model';
import { RoadPotholeTelemetry, RoadPotholeTelemetrySchema } from './models/road-pothole-telemetry.model';
import { FailAlert, FailAlertSchema } from './models/fail-alert.model';
import { FailAlertService } from './services/fail-alert/fail-alert.service';
import { FailTelemetryResolver } from './resolvers/fail-alert.resolver';
import { RainTelemetry, RainTelemetrySchema } from './models/rain-telemetry.model';
import { RainTelemetryService } from './services/rain-telemetry/rain-telemetry.service';
import { RainTelemetryResolver } from './resolvers/rain-telemetry.resolver';
import { DeviceModule } from '../device/device.module';

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
        FailAlertService,
        RainTelemetryService,

        // === RESOLVERs ===
        TelemetryResolver,
        TemperatureTelemetryResolver,
        HumidityTelemetryResolver,
        TransitTelemetryResolver,
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
                        name: TransitTelemetry.name,
                        schema: TransitTelemetrySchema
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
                        name: RainTelemetry.name,
                        schema: RainTelemetrySchema
                    },
                ]
            },
            {
                name: FailAlert.name,
                schema: FailAlertSchema
            },
        ]),
        UserModule,
        DeviceModule,
    ],
    exports: [
    ],
})
export class TelemetryModule {}
