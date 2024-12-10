import { Injectable } from '@nestjs/common';
import { CreateStaticGuardDto } from '../../dto/create-static-guard.dto';
import { Model } from 'mongoose';
import { StaticGuard } from '../../models/static-guard.model';
import { InjectModel } from '@nestjs/mongoose';

@Injectable()
export class StaticGuardService {

    constructor(@InjectModel(StaticGuard.name) private staticGuardModel: Model<StaticGuard>) {}

    async findById(deviceId: string): Promise<StaticGuard> {
        return this.staticGuardModel.findById(deviceId).exec();
    }

    async findAll(): Promise<StaticGuard[]> {
        return this.staticGuardModel.find().exec()
    }

    async create(data: CreateStaticGuardDto): Promise<StaticGuard> {
        return this.staticGuardModel.create({...data});
    }

}
