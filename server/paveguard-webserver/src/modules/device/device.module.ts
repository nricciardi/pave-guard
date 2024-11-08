import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Device, DeviceSchema } from './models/device.model';
import { StaticGuard, StaticGuardSchema } from './models/static-guard.model';
import { DynamicGuard, DynamicGuardSchema } from './models/dynamic-guard.model';
import { StaticGuardService } from './services/static-guard/static-guard.service';
import { StaticGuardResolver } from './resolvers/static-guard.resolver';
import { UserModule } from '../user/user.module';
import { DynamicGuardService } from './services/dynamic-guard/dynamic-guard.service';
import { DynamicGuardResolver } from './resolvers/dynamic-guard.resolver';

@Module({
    imports: [
        MongooseModule.forFeature([
            {
                name: Device.name,
                schema: DeviceSchema,
                discriminators: [
                    {
                        name: StaticGuard.name,
                        schema: StaticGuardSchema
                    },
                    {
                        name: DynamicGuard.name,
                        schema: DynamicGuardSchema
                    },
                ]
            },
        ]),
        UserModule
    ],
    providers: [
        // === SERVICEs ===
        StaticGuardService,
        DynamicGuardService,

        // === RESOLVERs ===
        StaticGuardResolver,
        DynamicGuardResolver,
    ]
})
export class DeviceModule {}
