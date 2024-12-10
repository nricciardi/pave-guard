import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TemperatureTelemetry } from 'src/modules/telemetry/models/temperature-telemetry.model';
import { CreateTemperatureTelemetryDto } from '../../dto/create-temperature-telemetry.dto';
import { TelemetryService } from '../telemetry/telemetry.service';

@Injectable()
export class TemperatureTelemetryService {
    constructor(private telemetryService: TelemetryService, @InjectModel(TemperatureTelemetry.name) private temperatureTelemetryModel: Model<TemperatureTelemetry>) {
    }

    async findAll(): Promise<TemperatureTelemetry[]> {
        return this.temperatureTelemetryModel.find().exec()
    }

    async create(data: CreateTemperatureTelemetryDto): Promise<TemperatureTelemetry> {

        return this.temperatureTelemetryModel.create({
            ...await this.telemetryService.buildStaticFieldsByDeviceId(data.deviceId),
            ...data
        });
    }
}
