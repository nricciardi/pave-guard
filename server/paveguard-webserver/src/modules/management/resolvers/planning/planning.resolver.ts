import { Args, Field, ID, Mutation, ObjectType, Query, Resolver } from '@nestjs/graphql';
import { PlanningService } from '../../services/planning/planning.service';
import { CreatePlanningDto } from '../../dto/create-planning.dto';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { UpdatePlanningDto } from '../../dto/update-planning.dto';


@ObjectType()
export class PlanningCalendarQuery {

  @Field(() => ID)
  id: string;

  @Field()
  road: string;

  @Field()
  city: string;

  @Field({
    nullable: true
  })
  county?: string;

  @Field({
    nullable: true
  })
  description?: string;

  @Field()
  state: string;

  @Field()
  date: Date

  @Field()
  done: boolean
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
    async updatePlanning(
        @Args("planningId") planningId: string,
        @Args() input: UpdatePlanningDto,
    ) {
        return this.planningService.updatePlanning(planningId, input);
    }

    @Mutation(() => PlanningCalendarQuery)
    @UseGuards(AdminGuard)
    async deletePlanning(
        @Args("planningId") planningId: string,
    ) {
        return this.planningService.deletePlanningById(planningId);
    }
}
