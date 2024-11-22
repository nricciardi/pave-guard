import { Injectable } from '@nestjs/common';
import { FailTelemetry } from '../../models/fail-telemetry.model';
import { CreateFailTelemetryDto } from '../../dto/create-fail-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class FailTelemetryService {
    constructor(@InjectModel(FailTelemetry.name) private failTelemetryModel: Model<FailTelemetry>) {
    }

    async findAll(): Promise<FailTelemetry[]> {
        return this.failTelemetryModel.find().exec()
    }

    async create(data: CreateFailTelemetryDto): Promise<FailTelemetry> {
        return this.failTelemetryModel.create({ ...data });
    }
}
