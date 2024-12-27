import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TemperatureTelemetry } from 'src/modules/telemetry/models/temperature-telemetry.model';
import { CreateTemperatureTelemetryDto } from '../../dto/create-temperature-telemetry.dto';
import { TelemetryCrud, TelemetryService } from '../telemetry/telemetry.service';
import { TelemetryFilters } from '../../dto/create-telemetry.dto';

@Injectable()
export class TemperatureTelemetryService implements TelemetryCrud<TemperatureTelemetry, CreateTemperatureTelemetryDto> {
    constructor(private telemetryService: TelemetryService, @InjectModel(TemperatureTelemetry.name) private temperatureTelemetryModel: Model<TemperatureTelemetry>) {
    }

    async findAll(filters?: TelemetryFilters): Promise<TemperatureTelemetry[]> {
        return this.temperatureTelemetryModel.find(this.telemetryService.buildQuery(filters)).exec()
    }

    async create(data: CreateTemperatureTelemetryDto): Promise<TemperatureTelemetry> {

        return this.temperatureTelemetryModel.create({
            ...await this.telemetryService.buildStaticFieldsByDeviceId(data.deviceId),
            ...data
        });
    }
}
