import { Injectable } from '@nestjs/common';
import { RainTelemetry } from '../../models/rain-telemetry.model';
import { CreateRainTelemetryDto } from '../../dto/create-rain-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TelemetryService } from '../telemetry/telemetry.service';

@Injectable()
export class RainTelemetryService {

    constructor(private telemetryService: TelemetryService, @InjectModel(RainTelemetry.name) private rainTelemetryModel: Model<RainTelemetry>) {
    }

    async findAll(): Promise<RainTelemetry[]> {
        return this.rainTelemetryModel.find().exec()
    }

    async create(data: CreateRainTelemetryDto): Promise<RainTelemetry> {

        return this.rainTelemetryModel.create({
            ...await this.telemetryService.buildStaticFieldsByDeviceId(data.deviceId),
            ...data
        });
    }
}
