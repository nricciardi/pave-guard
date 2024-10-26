import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TemperatureTelemetry } from 'src/modules/telemetry/temperature-telemetry/models/temperature-telemetry-schema.model';
import { CreateTemperatureTelemetryDto } from '../dto/create-temperature-telemetry.dto';

@Injectable()
export class TemperatureTelemetryService {
    constructor(@InjectModel(TemperatureTelemetry.name) private temperatureTelemetryModel: Model<TemperatureTelemetry>) {
    }

    async findAll(): Promise<TemperatureTelemetry[]> {
        return this.temperatureTelemetryModel.find().exec()
    }

    async create(data: CreateTemperatureTelemetryDto): Promise<TemperatureTelemetry> {
        return this.temperatureTelemetryModel.create({ ...data });
    }
}
