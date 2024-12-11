import { Module } from '@nestjs/common';
import { PlanningResolver } from './resolvers/planning/planning.resolver';
import { MongooseModule } from '@nestjs/mongoose';
import { PlanningCalendar, PlanningCalendarSchema } from './models/planning-calendar.model';
import { PlanningService } from './services/planning/planning.service';
import { UserModule } from '../user/user.module';

@Module({
  providers: [
    PlanningResolver,
    PlanningService
  ],
  imports: [
    MongooseModule.forFeature([
      {
          name: PlanningCalendar.name,
          schema: PlanningCalendarSchema,
      },
    ]),
    UserModule,
  ]
})
export class ManagementModule {}
