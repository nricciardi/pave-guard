import { Injectable } from '@nestjs/common';
import { FailAlert } from '../../models/fail-alert.model';
import { CreateFailTelemetryDto } from '../../dto/create-fail-telemetry.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TelemetryService } from '../telemetry/telemetry.service';

@Injectable()
export class FailTelemetryService {
    constructor(@InjectModel(FailAlert.name) private failTelemetryModel: Model<FailAlert>) {
    }

    async findAll(): Promise<FailAlert[]> {
        return this.failTelemetryModel.find().exec()
    }

    async create(data: CreateFailTelemetryDto): Promise<FailAlert> {
        return this.failTelemetryModel.create({
            metadata: {
                deviceId: data.deviceId,
            },
            ...data
        });
    }
}
