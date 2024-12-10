import { Injectable } from '@nestjs/common';
import { DynamicGuard } from '../../models/dynamic-guard.model';
import { Model } from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import { CreateDynamicGuardDto } from '../../dto/create-dynamic-guard.dto';

@Injectable()
export class DynamicGuardService {
    constructor(@InjectModel(DynamicGuard.name) private dynamicGuardModel: Model<DynamicGuard>) {}

    async findById(deviceId: string): Promise<DynamicGuard> {
        return this.dynamicGuardModel.findById(deviceId).exec();
    }

    async findAll(): Promise<DynamicGuard[]> {
        return this.dynamicGuardModel.find().exec()
    }

    async findByUserId(userId: number): Promise<DynamicGuard[]> {
        return this.dynamicGuardModel.find({
            userId
        }).exec()
    }

    async create(data: CreateDynamicGuardDto): Promise<DynamicGuard> {
        return this.dynamicGuardModel.create({...data});
    }
}
