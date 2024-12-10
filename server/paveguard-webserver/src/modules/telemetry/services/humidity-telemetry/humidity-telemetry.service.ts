import { Injectable } from '@nestjs/common';
import { HumidityTelemetry } from '../../models/humidity-telemetry.model';
import { Model } from 'mongoose';
import { CreateHumidityTelemetryDto } from '../../dto/create-humidity-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { TelemetryService } from '../telemetry/telemetry.service';

@Injectable()
export class HumidityTelemetryService {
    constructor(private telemetryService: TelemetryService, @InjectModel(HumidityTelemetry.name) private humidityTelemetryModel: Model<HumidityTelemetry>) {
    }

    async findAll(): Promise<HumidityTelemetry[]> {
        return this.humidityTelemetryModel.find().exec()
    }

    async create(data: CreateHumidityTelemetryDto): Promise<HumidityTelemetry> {

        return this.humidityTelemetryModel.create({
            ...await this.telemetryService.buildStaticFieldsByDeviceId(data.deviceId),
            ...data
        });
    }
}