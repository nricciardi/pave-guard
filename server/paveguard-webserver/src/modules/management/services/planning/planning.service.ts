import { Injectable } from '@nestjs/common';
import { PlanningCalendar } from '../../models/planning-calendar.model';
import { CreatePlanningDto } from '../../dto/create-planning.dto';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class PlanningService {

    constructor(
        private readonly configService: ConfigService,
        @InjectModel(PlanningCalendar.name) private planningCalendarModel: Model<PlanningCalendar>
    ) {}

  async createPlanning(input: CreatePlanningDto): Promise<PlanningCalendar> {

    const newPlanning = new this.planningCalendarModel(input);

    return newPlanning.save();
  }

  async deletePlanningById(planningId: string): Promise<PlanningCalendar> {

    return this.planningCalendarModel.findByIdAndDelete({
      _id: planningId
    }).exec();
  }

  async calendar(): Promise<PlanningCalendar[]> {
    return this.planningCalendarModel.find().exec();
  }
}
