import { Args, Field, ID, Mutation, ObjectType, Query, Resolver } from '@nestjs/graphql';
import { PlanningService } from '../../services/planning/planning.service';
import { CreatePlanningDto } from '../../dto/create-planning.dto';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';


@ObjectType()
export class PlanningCalendarQuery {

  @Field(() => ID)
  id: string;

  @Field()
  road: string;

  @Field()
  city: string;

  @Field()
  county?: string;

  @Field()
  state: string;

  @Field()
  date: Date
}


@Resolver()
export class PlanningResolver {

    constructor(
        private readonly planningService: PlanningService,
    ) {}

    @Query(() => [PlanningCalendarQuery])
    @UseGuards(AdminGuard)
    async planningCalendar() {
        return this.planningService.calendar();
    }

    @Mutation(() => PlanningCalendarQuery)
    @UseGuards(AdminGuard)
    async createPlanning(
        @Args() input: CreatePlanningDto,
    ) {
        return this.planningService.createPlanning(input);
    }

    @Mutation(() => PlanningCalendarQuery)
    @UseGuards(AdminGuard)
    async deletePlanning(
        @Args("planningId") planningId: string,
    ) {
        return this.planningService.deletePlanningById(planningId);
    }
}
