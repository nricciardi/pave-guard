import { Injectable } from '@nestjs/common';
import { FailAlert } from '../../models/fail-alert.model';
import { CreateFailTelemetryDto } from '../../dto/create-fail-alert.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TelemetryService } from '../telemetry/telemetry.service';

@Injectable()
export class FailAlertService {
    constructor(private telemetryService: TelemetryService, @InjectModel(FailAlert.name) private failAlertModel: Model<FailAlert>) {
    }

    async findAll(): Promise<FailAlert[]> {
        return this.failAlertModel.find().exec()
    }

    async create(data: CreateFailTelemetryDto): Promise<FailAlert> {
        return this.failAlertModel.create({
            metadata: {
                deviceId: data.deviceId
            },
            ...data
        });
    }
}
