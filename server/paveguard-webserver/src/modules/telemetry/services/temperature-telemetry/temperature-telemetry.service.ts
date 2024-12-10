import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TemperatureTelemetry } from 'src/modules/telemetry/models/temperature-telemetry.model';
import { TelemetryCreateInput } from '../telemetry/telemetry.service';
import { IsNotEmpty, IsNumber, IsString } from 'class-validator';


export class TemperatureTelemetryCreateInput extends TelemetryCreateInput {
    @IsNumber()
    @IsNotEmpty()
    temperature: number;
}



@Injectable()
export class TemperatureTelemetryService {
    constructor(@InjectModel(TemperatureTelemetry.name) private temperatureTelemetryModel: Model<TemperatureTelemetry>) {
    }

    async findAll(): Promise<TemperatureTelemetry[]> {
        return this.temperatureTelemetryModel.find().exec()
    }

    async create(data: TemperatureTelemetryCreateInput): Promise<TemperatureTelemetry> {

        return this.temperatureTelemetryModel.create(data);
    }
}
