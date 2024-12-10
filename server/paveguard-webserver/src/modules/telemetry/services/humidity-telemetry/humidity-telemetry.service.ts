import { Injectable } from '@nestjs/common';
import { HumidityTelemetry } from '../../models/humidity-telemetry.model';
import { Model } from 'mongoose';
import { CreateHumidityTelemetryDto } from '../../dto/create-humidity-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';

@Injectable()
export class HumidityTelemetryService {
    constructor(@InjectModel(HumidityTelemetry.name) private humidityTelemetryModel: Model<HumidityTelemetry>) {
    }

    async findAll(): Promise<HumidityTelemetry[]> {
        return this.humidityTelemetryModel.find().exec()
    }

    async create(data: HumidityTelemetry): Promise<HumidityTelemetry> {
        return this.humidityTelemetryModel.create(data);
    }
}