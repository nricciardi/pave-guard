import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Telemetry } from '../../models/telemetry.model';
import { StaticGuardService } from 'src/modules/device/services/static-guard/static-guard.service';

@Injectable()
export class TelemetryService {

    constructor(private deviceService: StaticGuardService, @InjectModel(Telemetry.name) private telemetryModel: Model<Telemetry>) {
    }

    async findAll(): Promise<Telemetry[]> {
        return this.telemetryModel.find().exec();
    }

    async buildStaticFieldsByDeviceId(deviceId: string): Promise<object> {

        const device = await this.deviceService.findById(deviceId);

        return {
            metadata: {
                deviceId: deviceId,
                road: device.road,
            },
            latitude: device.latitude,
            longitude: device.longitude,
        }   
    }
}
